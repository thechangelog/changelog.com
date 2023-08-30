defmodule ChangelogWeb.Admin.EpisodeRequestController do
  use ChangelogWeb, :controller

  alias Changelog.{EpisodeRequest, Podcast, Notifier}

  plug :assign_podcast
  plug :assign_request when action not in [:index]
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
      |> EpisodeRequest.with_unpublished_episode()
      |> EpisodeRequest.newest_first()
      |> EpisodeRequest.preload_all()
      |> Repo.all()

    complete =
      requests
      |> EpisodeRequest.with_published_episode()
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
    |> assign(:complete, complete)
    |> assign(:declined, declined)
    |> assign(:failed, failed)
    |> render(:index)
  end

  def edit(conn = %{assigns: %{request: request}}, _params, _podcast) do
    changeset = EpisodeRequest.admin_changeset(request)

    conn
    |> assign(:changeset, changeset)
    |> render(:edit)
  end

  def update(
        conn = %{assigns: %{request: request}},
        params = %{"episode_request" => request_params},
        _podcast
      ) do
    changeset = EpisodeRequest.admin_changeset(request, request_params)

    case Repo.update(changeset) do
      {:ok, request} ->
        request =
          request
          |> Repo.reload()
          |> EpisodeRequest.preload_podcast()

        params =
          replace_next_edit_path(
            params,
            ~p"/admin/podcasts/#{request.podcast.slug}/edit"
          )

        conn
        |> put_flash(:result, "success")
        |> redirect_next(
          params,
          ~p"/admin/podcasts/#{request.podcast.slug}/episode_requests"
        )

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, request: request, changeset: changeset)
    end
  end

  def show(conn = %{assigns: %{request: request}}, _params, _podcast) do
    conn
    |> assign(:request, request)
    |> render(:show)
  end

  def delete(conn = %{assigns: %{request: request}}, params, podcast) do
    Repo.delete!(request)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  def decline(conn = %{assigns: %{request: request}}, params, podcast) do
    message = Map.get(params, "message", "")
    request = EpisodeRequest.decline!(request, message)
    Task.start_link(fn -> Notifier.notify(request) end)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  def fail(conn = %{assigns: %{request: request}}, params, podcast) do
    message = Map.get(params, "message", "")
    request = EpisodeRequest.fail!(request, message)
    Task.start_link(fn -> Notifier.notify(request) end)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  def pend(conn = %{assigns: %{request: request}}, params, podcast) do
    EpisodeRequest.pend!(request)

    conn
    |> put_flash(:result, "success")
    |> redirect_next_or_index(params, podcast)
  end

  defp assign_podcast(conn = %{params: %{"podcast_id" => slug}}, _) do
    podcast = Repo.get_by!(Podcast, slug: slug) |> Podcast.preload_active_hosts()
    assign(conn, :podcast, podcast)
  end

  defp assign_request(conn = %{params: %{"id" => id}}, _) do
    request =
      conn.assigns.podcast
      |> assoc(:episode_requests)
      |> EpisodeRequest.preload_all()
      |> Repo.get!(id)

    assign(conn, :request, request)
  end

  defp redirect_next_or_index(conn, params, podcast) do
    index_path = ~p"/admin/podcasts/#{podcast.slug}/episode_requests"
    redirect_next(conn, params, index_path)
  end
end
