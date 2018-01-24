defmodule ChangelogWeb.Admin.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, EpisodeTopic, EpisodeHost, EpisodeStat, Mailer,
                   Podcast, Transcripts}
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

    stats =
      episode
      |> assoc(:episode_stats)
      |> EpisodeStat.newest_first
      |> Repo.all

    render(conn, :show, episode: episode, stats: stats)
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
      {:ok, _episode} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_podcast_episode_path(conn, :index, podcast.slug))
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

  def publish(conn, params = %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)

    changeset = Ecto.Changeset.change(episode, %{published: true})

    case Repo.update(changeset) do
      {:ok, episode} ->
        handle_thanks_email(episode, params)

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

    Transcripts.Updater.update(episode)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_podcast_episode_path(conn, :index, podcast.slug))
  end

  defp assign_podcast(conn, _) do
    podcast = Repo.get_by!(Podcast, slug: conn.params["podcast_id"])
    assign(conn, :podcast, podcast)
  end

  defp handle_thanks_email(episode, params) do
    if Map.has_key?(params, "thanks") do
      episode = Episode.preload_guests(episode)
      email_opts = Map.take(params, ["from", "reply", "subject", "message"])

      for guest <- episode.guests do
        Email.guest_thanks(guest, email_opts) |> Mailer.deliver_later
      end
    end
  end
end
