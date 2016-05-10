defmodule Changelog.Admin.EpisodeController do
  use Changelog.Web, :controller

  alias Changelog.{Podcast, Episode, EpisodeHost}

  plug :assign_podcast
  plug :scrub_params, "episode" when action in [:create, :update]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply __MODULE__, action_name(conn), arg_list
  end

  def index(conn, _params, podcast) do
    query = from e in Episode,
      where: e.podcast_id == ^podcast.id,
      order_by: [desc: e.id]

    episodes = Repo.all query
    render conn, "index.html", episodes: episodes
  end

  def new(conn, _params, podcast) do
    podcast = podcast |> Repo.preload(:hosts)

    default_hosts =
      podcast.hosts
      |> Enum.with_index(1)
      |> Enum.map(&EpisodeHost.build_and_preload/1)

    default_slug = case Podcast.last_numbered_slug(podcast) do
      {float, _} -> round(Float.floor(float) + 1)
      _ -> ""
    end

    changeset =
      podcast
      |> build_assoc(:episodes, episode_hosts: default_hosts, slug: default_slug)
      |> Episode.changeset

    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"episode" => episode_params}, podcast) do
    changeset =
      build_assoc(podcast, :episodes)
      |> Episode.preload_all
      |> Episode.changeset(episode_params)

    case Repo.insert(changeset) do
      {:ok, episode} ->
        conn
        |> put_flash(:info, "#{episode.title} created!")
        |> redirect(to: admin_podcast_episode_path(conn, :index, podcast))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end

  def edit(conn, %{"id" => id}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get!(id)
      |> Episode.preload_all

    changeset = Episode.changeset(episode)
    render conn, "edit.html", episode: episode, changeset: changeset
  end

  def update(conn, %{"id" => id, "episode" => episode_params}, podcast) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get!(id)
      |> Episode.preload_all

    changeset = Episode.changeset(episode, episode_params)

    case Repo.update(changeset) do
      {:ok, episode} ->
        conn
        |> put_flash(:info, "#{episode.title} updated!")
        |> redirect(to: admin_podcast_episode_path(conn, :index, podcast))
      {:error, changeset} ->
        render conn, "edit.html", episode: episode, changeset: changeset
    end
  end

  defp assign_podcast(conn, _) do
    podcast = Repo.get! Podcast, conn.params["podcast_id"]
    assign conn, :podcast, podcast
  end
end
