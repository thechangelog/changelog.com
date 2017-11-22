defmodule ChangelogWeb.Admin.NewsSourceController do
  use ChangelogWeb, :controller

  alias Changelog.NewsSource

  plug :scrub_params, "news_source" when action in [:create, :update]

  def index(conn, params) do
    page = NewsSource
    |> order_by([s], desc: s.id)
    |> Repo.paginate(params)

    render(conn, :index, news_sources: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = NewsSource.admin_changeset(%NewsSource{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"news_source" => source_params}) do
    changeset = NewsSource.admin_changeset(%NewsSource{}, source_params)

    case Repo.insert(changeset) do
      {:ok, news_source} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(news_source, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    news_source = Repo.get!(NewsSource, id)
    changeset = NewsSource.admin_changeset(news_source)
    render(conn, :edit, news_source: news_source, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_source" => source_params}) do
    news_source = Repo.get!(NewsSource, id)
    changeset = NewsSource.admin_changeset(news_source, source_params)

    case Repo.update(changeset) do
      {:ok, news_source} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(news_source, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, news_source: news_source, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    news_source = Repo.get!(NewsSource, id)
    Repo.delete!(news_source)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_source_path(conn, :index))
  end

  defp smart_redirect(conn, _news_source, %{"close" => _true}) do
    redirect(conn, to: admin_news_source_path(conn, :index))
  end
  defp smart_redirect(conn, news_source, _params) do
    redirect(conn, to: admin_news_source_path(conn, :edit, news_source))
  end
end
