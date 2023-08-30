defmodule ChangelogWeb.Admin.NewsSourceController do
  use ChangelogWeb, :controller

  alias Changelog.{Fastly, NewsSource}

  plug :assign_source when action in [:edit, :update, :delete]
  plug Authorize, [Policies.AdminsOnly, :source]
  plug :scrub_params, "news_source" when action in [:create, :update]

  def index(conn, params) do
    page =
      NewsSource
      |> order_by([s], desc: s.id)
      |> Repo.paginate(params)

    render(conn, :index, sources: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = NewsSource.insert_changeset(%NewsSource{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"news_source" => source_params}) do
    changeset = NewsSource.insert_changeset(%NewsSource{}, source_params)

    case Repo.insert(changeset) do
      {:ok, source} ->
        Repo.update(NewsSource.file_changeset(source, source_params))

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/news/sources/#{source}/edit")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{source: source}}, _params) do
    changeset = NewsSource.update_changeset(source)
    render(conn, :edit, source: source, changeset: changeset)
  end

  def update(conn = %{assigns: %{source: source}}, params = %{"news_source" => source_params}) do
    changeset = NewsSource.update_changeset(source, source_params)

    case Repo.update(changeset) do
      {:ok, source} ->
        Fastly.purge(source)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/news/sources")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, source: source, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{source: source}}, _params) do
    Repo.delete!(source)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: ~p"/admin/news/sources")
  end

  defp assign_source(conn = %{params: %{"id" => id}}, _) do
    source = Repo.get!(NewsSource, id)
    assign(conn, :source, source)
  end
end
