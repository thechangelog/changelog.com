defmodule ChangelogWeb.Admin.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, EpisodeTopic, EpisodeHost, EpisodeStat, Github,
                   Mailer, NewsItem, NewsQueue, Podcast}
  alias ChangelogWeb.Email

  plug :assign_podcast
  plug :scrub_params, "episode" when action in [:create, :update]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def index(conn, params, podcast) do
    episodes = assoc(podcast, :episodes)

    page =
      episodes
      |> Episode.published
      |> Episode.newest_first
      |> Repo.paginate(params)

    scheduled =
      episodes
      |> Episode.scheduled
      |> Episode.newest_first
      |> Repo.all

    drafts =
      episodes
      |> Episode.unpublished
      |> Episode.newest_first(:recorded_at)
      |> Repo.all

    render(conn, :index, episodes: page.entries, scheduled: scheduled, drafts: drafts, page: page)
  end

  def show(conn, %{"id" => slug}, podcast) do
    episode =
      podcast
      |> assoc(:episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    news_item =
      NewsItem
      |> NewsItem.published
      |> NewsItem.with_episode(episode)
      |> Repo.one

    stats =
      episode
      |> assoc(:episode_stats)
      |> EpisodeStat.newest_first
      |> Repo.all

    render(conn, :show, episode: episode, item: news_item, stats: stats)
  end

  def new(conn, _params, podcast) do
    podcast =
      podcast
      |> Podcast.preload_topics
      |> Podcast.preload_hosts

    default_hosts =
      podcast.hosts
      |> Enum.with_index(1)
      |> Enum.map(&EpisodeHost.build_and_preload/1)

    default_topics =
      podcast.topics
      |> Enum.with_index(1)
      |> Enum.map(&EpisodeTopic.build_and_preload/1)

    default_slug = Podcast.last_numbered_slug(podcast) + 1

    changeset =
      podcast
      |> build_assoc(:episodes,
        episode_topics: default_topics,
        episode_hosts: default_hosts,
        recorded_live: podcast.recorded_live,
        slug: default_slug)
      |> Episode.admin_changeset

    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"episode" => episode_params}, podcast) do
    changeset =
      build_assoc(podcast, :episodes)
      |> Episode.preload_all
      |> Episode.admin_changeset(episode_params)

    case Repo.insert(changeset) do
      {:ok, episode} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_podcast_episode_path(conn, :edit, podcast.slug, episode.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    changeset = Episode.admin_changeset(episode)
    render(conn, :edit, episode: episode, changeset: changeset)
  end

  def update(conn, params = %{"id" => slug, "episode" => episode_params}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    changeset = Episode.admin_changeset(episode, episode_params)

    case Repo.update(changeset) do
      {:ok, _episode} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_podcast_episode_path(conn, :index, podcast.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, episode: episode, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Episode.unpublished
      |> Repo.get_by!(slug: slug)

    Repo.delete!(episode)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
  end

  def publish(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)

    changeset = Ecto.Changeset.change(episode, %{published: true})

    case Repo.update(changeset) do
      {:ok, episode} ->
        handle_thanks_email(conn, episode)
        handle_news_item(conn, episode)

        conn
        |> put_flash(:result, "success")
        |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, episode: episode, changeset: changeset)
    end
  end

  def unpublish(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)

    changeset = Ecto.Changeset.change(episode, %{published: false})

    case Repo.update(changeset) do
      {:ok, _episode} ->
        conn
        |> put_flash(:result, "success")
        |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, episode: episode, changeset: changeset)
    end
  end

  def transcript(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)

    Github.Updater.update(episode, "transcripts")
    # TODO Github.Updater.update(episode, "show-notes")

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
  end

  defp assign_podcast(conn, _) do
    podcast = Repo.get_by!(Podcast, slug: conn.params["podcast_id"])
    assign(conn, :podcast, podcast)
  end

  defp handle_news_item(conn = %{params: %{"news" => _}}, episode) do
    episode =
      episode
      |> Episode.preload_podcast
      |> Episode.preload_topics

    topics = Enum.map(episode.episode_topics, fn(t) -> Map.take(t, [:topic_id, :position]) end)

    %NewsItem{
      type: :audio,
      object_id: "#{episode.podcast.slug}:#{episode.slug}",
      url: episode_url(conn, :show, episode.podcast.slug, episode.slug),
      headline: (episode.headline || episode.title),
      story: episode.summary,
      published_at: episode.published_at,
      logger_id: conn.assigns.current_user.id,
      news_item_topics: topics}
    |> NewsItem.insert_changeset
    |> Repo.insert!
    |> NewsQueue.append
  end
  defp handle_news_item(_, _), do: false

  defp handle_thanks_email(conn = %{params: %{"thanks" => _}}, episode) do
    episode = Episode.preload_guests(episode)
    email_opts = Map.take(conn.params, ["from", "reply", "subject", "message"])

    for guest <- episode.guests do
      Email.guest_thanks(guest, email_opts) |> Mailer.deliver_later
    end
  end
  defp handle_thanks_email(_, _), do: false
end
