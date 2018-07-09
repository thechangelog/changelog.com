defmodule ChangelogWeb.Admin.PodcastController do
  use ChangelogWeb, :controller

  alias Changelog.Podcast

  plug :scrub_params, "podcast" when action in [:create, :update]

  def index(conn, _params) do
    ours =
      Podcast.ours
      |> Podcast.not_retired
      |> Podcast.by_position
      |> Repo.all

    partners =
      Podcast.partners
      |> Podcast.not_retired
      |> Podcast.oldest_first
      |> Repo.all

    retired =
      Podcast.retired
      |> Podcast.oldest_first
      |> Repo.all

    render(conn, :index, ours: ours, partners: partners, retired: retired)
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
        clear_podcasts_cache()

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_podcast_path(conn, :edit, podcast.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)
      |> Repo.preload([podcast_hosts: {Changelog.PodcastHost.by_position, :person}])
      |> Repo.preload([podcast_topics: {Changelog.PodcastTopic.by_position, :topic}])
    changeset = Podcast.update_changeset(podcast)
    render(conn, :edit, podcast: podcast, changeset: changeset)
  end

  def update(conn, params = %{"id" => slug, "podcast" => podcast_params}) do
    podcast = Repo.get_by!(Podcast, slug: slug)
      |> Repo.preload(:podcast_topics)
      |> Repo.preload(:podcast_hosts)
    changeset = Podcast.update_changeset(podcast, podcast_params)

    case Repo.update(changeset) do
      {:ok, _podcast} ->
        clear_podcasts_cache()

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_podcast_path(conn, :index))
      {:error, changeset} ->
        render(conn, :edit, podcast: podcast, changeset: changeset)
    end
  end

  defp clear_podcasts_cache, do: ConCache.delete(:app_cache, "podcasts")
end
