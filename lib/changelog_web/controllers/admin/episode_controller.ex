defmodule ChangelogWeb.Admin.EpisodeController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, EpisodeChannel, EpisodeHost, EpisodeStat, Mailer,
                   Podcast, Transcripts}
  alias ChangelogWeb.Email

  plug :assign_podcast
  plug :scrub_params, "episode" when action in [:create, :update]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply __MODULE__, action_name(conn), arg_list
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
      |> Episode.newest_first(:inserted_at)
      |> Repo.all

    render(conn, "index.html", episodes: page.entries, scheduled: scheduled, drafts: drafts, page: page)
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

    render(conn, "show.html", episode: episode, stats: stats)
  end

  def new(conn, _params, podcast) do
    podcast =
      podcast
      |> Podcast.preload_channels
      |> Podcast.preload_hosts

    default_hosts =
      podcast.hosts
      |> Enum.with_index(1)
      |> Enum.map(&EpisodeHost.build_and_preload/1)

    default_channels =
      podcast.channels
      |> Enum.with_index(1)
      |> Enum.map(&EpisodeChannel.build_and_preload/1)

    default_slug = Podcast.last_numbered_slug(podcast) + 1

    changeset =
      podcast
      |> build_assoc(:episodes,
        episode_channels: default_channels,
        episode_hosts: default_hosts,
        recorded_live: podcast.recorded_live,
        slug: default_slug)
      |> Episode.admin_changeset

    render(conn, "new.html", changeset: changeset)
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
        |> smart_redirect(podcast, episode, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => slug}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    changeset = Episode.admin_changeset(episode)
    render(conn, "edit.html", episode: episode, changeset: changeset)
  end

  def update(conn, params = %{"id" => slug, "episode" => episode_params}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    changeset = Episode.admin_changeset(episode, episode_params)

    case Repo.update(changeset) do
      {:ok, episode} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(podcast, episode, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", episode: episode, changeset: changeset)
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
        |> render("edit.html", episode: episode, changeset: changeset)
    end
  end

  def unpublish(conn, _params = %{"id" => slug}, podcast) do
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
        |> render("edit.html", episode: episode, changeset: changeset)
    end
  end

  def transcript(conn, _params = %{"id" => slug}, podcast) do
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
    assign conn, :podcast, podcast
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

  defp smart_redirect(conn, podcast, _episode, %{"close" => _true}) do
    redirect(conn, to: admin_podcast_episode_path(conn, :index, podcast.slug))
  end
  defp smart_redirect(conn, podcast, episode, _params) do
    redirect(conn, to: admin_podcast_episode_path(conn, :edit, podcast.slug, episode.slug))
  end
end
