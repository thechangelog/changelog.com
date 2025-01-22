defmodule ChangelogWeb.Admin.PodcastController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, FeedStat, Podcast}
  alias Changelog.ObanWorkers.FeedUpdater

  plug :assign_podcast when action in [:show, :edit, :update, :feed, :agents]
  plug Authorize, [Policies.Admin.Podcast, :podcast]
  plug :scrub_params, "podcast" when action in [:create, :update]

  def index(conn = %{assigns: %{current_user: user}}, _params) do
    draft =
      Podcast.draft()
      |> Podcast.preload_active_hosts()
      |> Repo.all()
      |> Enum.filter(fn p -> Policies.Admin.Podcast.show(user, p) end)

    active =
      Podcast.active()
      |> Podcast.by_position()
      |> Podcast.preload_active_hosts()
      |> Repo.all()
      |> Enum.filter(fn p -> Policies.Admin.Podcast.show(user, p) end)

    inactive =
      Podcast.inactive()
      |> Podcast.by_position()
      |> Podcast.preload_active_hosts()
      |> Repo.all()
      |> Enum.filter(fn p -> Policies.Admin.Podcast.show(user, p) end)

    archived =
      Podcast.archived()
      |> Podcast.oldest_first()
      |> Podcast.preload_active_hosts()
      |> Repo.all()
      |> Enum.filter(fn p -> Policies.Admin.Podcast.show(user, p) end)

    conn
    |> assign(:draft, draft)
    |> assign(:active, active)
    |> assign(:inactive, inactive)
    |> assign(:archived, archived)
    |> assign(:downloads, ChangelogWeb.Admin.PageController.downloads())
    |> render(:index)
  end

  def new(conn, _params) do
    changeset = Podcast.insert_changeset(%Podcast{podcast_hosts: []})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"podcast" => podcast_params}) do
    changeset = Podcast.insert_changeset(%Podcast{}, podcast_params)

    case Repo.insert(changeset) do
      {:ok, podcast} ->
        Repo.update(Podcast.file_changeset(podcast, podcast_params))
        FeedUpdater.queue(podcast)
        Cache.delete(podcast)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/podcasts/#{podcast.slug}/edit")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def show(conn = %{assigns: %{podcast: podcast}}, _params) do
    redirect(conn, to: ~p"/admin/podcasts/#{podcast.slug}/episodes")
  end

  def edit(conn = %{assigns: %{podcast: podcast}}, _params) do
    podcast =
      podcast
      |> Podcast.preload_hosts()
      |> Podcast.preload_topics()

    changeset = Podcast.update_changeset(podcast)

    render(conn, :edit, podcast: podcast, changeset: changeset)
  end

  def update(conn = %{assigns: %{podcast: podcast}}, params = %{"podcast" => podcast_params}) do
    podcast =
      podcast
      |> Repo.preload(:podcast_topics)
      |> Repo.preload(:podcast_hosts)

    changeset = Podcast.update_changeset(podcast, podcast_params)

    case Repo.update(changeset) do
      {:ok, podcast} ->
        FeedUpdater.queue(podcast)
        Cache.delete(podcast)

        params =
          replace_next_edit_path(params, ~p"/admin/podcasts/#{podcast.slug}/edit")

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/podcasts")

      {:error, changeset} ->
        render(conn, :edit, podcast: podcast, changeset: changeset)
    end
  end

  def feed(conn = %{assigns: %{podcast: podcast}}, _params) do
    FeedUpdater.queue(podcast)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: ~p"/admin/podcasts")
  end

  def agents(conn = %{assigns: %{podcast: podcast}}, params) do
    stat =
      if params["date"] do
        podcast
        |> assoc(:feed_stats)
        |> FeedStat.on_date(params["date"])
        |> FeedStat.limit(1)
        |> Repo.one()
      else
        podcast
        |> assoc(:feed_stats)
        |> FeedStat.newest_first()
        |> FeedStat.limit(1)
        |> Repo.one()
      end

    prev =
      FeedStat.previous_to(stat)
      |> FeedStat.newest_first()
      |> FeedStat.limit(1)
      |> Repo.one()

    next =
      FeedStat.next_after(stat)
      |> FeedStat.newest_last()
      |> FeedStat.limit(1)
      |> Repo.one()

    conn
    |> assign(:stat, stat)
    |> assign(:prev, prev)
    |> assign(:next, next)
    |> render(:agents)
  end

  defp assign_podcast(conn = %{params: %{"id" => id}}, _) do
    podcast = Repo.get_by!(Podcast, slug: id) |> Podcast.preload_hosts()
    assign(conn, :podcast, podcast)
  end
end
