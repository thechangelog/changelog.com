defmodule ChangelogWeb.Admin.EpisodeRequestController do
  use ChangelogWeb, :controller

  alias Changelog.{EpisodeRequest, Podcast}

  plug :assign_podcast
  plug Authorize, [Policies.EpisodeRequest, :podcast]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def index(conn, _params, podcast) do
    requests = assoc(podcast, :episode_requests)

    active =
      requests
      |> EpisodeRequest.active()
      |> EpisodeRequest.newest_first()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    archived =
      requests
      |> EpisodeRequest.declined()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    conn
    |> assign(:active, active)
    |> assign(:archived, archived)
    |> render(:index)
  end

  def show(conn, %{"id" => id}, podcast) do
    request =
      podcast
      |> assoc(:episode_requests)
      |> EpisodeRequest.preload_all()
      |> Repo.get!(id)

    conn
    |> assign(:request, request)
    |> render(:show)
  end

  def delete(conn, %{"id" => id}, podcast) do
    request =
      podcast
      |> assoc(:episode_requests)
      |> Repo.get!(id)

    Repo.delete!(request)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_podcast_episode_request_path(conn, :index, podcast.slug))
  end

  def decline(conn, %{"id" => id}, podcast) do
    request =
      podcast
      |> assoc(:episode_requests)
      |> Repo.get!(id)

    EpisodeRequest.decline!(request)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_podcast_episode_request_path(conn, :index, podcast.slug))
  end

  defp assign_podcast(conn = %{params: %{"podcast_id" => slug}}, _) do
    podcast = Repo.get_by!(Podcast, slug: slug) |> Podcast.preload_hosts()
    assign(conn, :podcast, podcast)
  end
end
