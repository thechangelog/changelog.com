defmodule ChangelogWeb.EpisodeRequestController do
  use ChangelogWeb, :controller

  alias Changelog.{EpisodeRequest}

  plug RequireUser, "before submitting" when action in [:create]

  def new(conn = %{assigns: %{podcasts: podcasts}}, params) do
    podcast = Enum.find(podcasts, fn(p) -> p.slug == params["slug"] end)

    {conn, podcast_id} = case podcast do
      nil -> {conn, 1}
      p -> {assign(conn, :podcast, p), p.id}
    end

    changeset = EpisodeRequest.submission_changeset(%EpisodeRequest{podcast_id: podcast_id})

    conn
    |> assign(:changeset, changeset)
    |> render(:new)
  end

  def create(conn = %{assigns: %{current_user: user}}, %{"episode_request" => request_params}) do
    request = %EpisodeRequest{submitter_id: user.id, status: :submitted}
    changeset = EpisodeRequest.submission_changeset(request, request_params)

    case Repo.insert(changeset) do
      {:ok, _request} ->
        conn
        |> put_flash(:success, "We received your episode request! Stay awesome 💚")
        |> redirect(to: root_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong. 😭")
        |> render(:new, changeset: changeset)
    end
  end
end
