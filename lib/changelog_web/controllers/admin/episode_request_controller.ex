defmodule ChangelogWeb.Admin.EpisodeRequestController do
  use ChangelogWeb, :controller

  alias Changelog.{EpisodeRequest, Podcast, Notifier}

  plug :assign_podcast
  plug Authorize, [Policies.Admin.EpisodeRequest, :podcast]

  # pass assigned podcast as a function arg
  def action(conn, _) do
    arg_list = [conn, conn.params, conn.assigns.podcast]
    apply(__MODULE__, action_name(conn), arg_list)
  end

  def index(conn, _params, podcast) do
    requests = assoc(podcast, :episode_requests)

    fresh =
      requests
      |> EpisodeRequest.sans_episode()
      |> EpisodeRequest.fresh()
      |> EpisodeRequest.newest_first()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    pending =
      requests
      |> EpisodeRequest.sans_episode()
      |> EpisodeRequest.pending()
      |> EpisodeRequest.newest_first()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    accepted =
      requests
      |> EpisodeRequest.with_episode()
      |> EpisodeRequest.newest_first()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    failed =
      requests
      |> EpisodeRequest.failed()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    declined =
      requests
      |> EpisodeRequest.declined()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    conn
    |> assign(:fresh, fresh)
    |> assign(:pending, pending)
    |> assign(:accepted, accepted)
    |> assign(:declined, declined)
    |> assign(:failed, failed)
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

  def delete(conn, params = %{"id" => id}, podcast) do
    request =
      podcast
      |> assoc(:episode_requests)
      |> Repo.get!(id)

    Repo.delete!(request)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  def decline(conn, params = %{"id" => id}, podcast) do
    message = Map.get(params, "message", "")

    request =
      podcast
      |> assoc(:episode_requests)
      |> Repo.get!(id)
      |> EpisodeRequest.decline!(message)

    Task.start_link(fn -> Notifier.notify(request) end)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  def fail(conn, params = %{"id" => id}, podcast) do
    request =
      podcast
      |> assoc(:episode_requests)
      |> Repo.get!(id)

    EpisodeRequest.fail!(request)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  def pend(conn, params = %{"id" => id}, podcast) do
    request =
      podcast
      |> assoc(:episode_requests)
      |> Repo.get!(id)

    EpisodeRequest.pend!(request)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  defp assign_podcast(conn = %{params: %{"podcast_id" => slug}}, _) do
    podcast = Repo.get_by!(Podcast, slug: slug) |> Podcast.preload_active_hosts()
    assign(conn, :podcast, podcast)
  end

  defp redirect_next_or_index(conn, params, podcast) do
    index_path = Routes.admin_podcast_episode_request_path(conn, :index, podcast.slug)
    redirect_next(conn, params, index_path)
  end
end
