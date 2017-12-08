defmodule ChangelogWeb.Admin.NewsIssueController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsIssue, NewsItem, NewsIssueItem}

  plug :scrub_params, "news_issue" when action in [:create, :update]

  def index(conn, params) do
    page =
      NewsIssue.published
      |> order_by([s], desc: s.id)
      |> NewsIssue.preload_all()
      |> Repo.paginate(params)

    drafts =
      NewsIssue.unpublished
      |> NewsIssue.newest_first(:inserted_at)
      |> Repo.all

    render(conn, :index, news_issues: page.entries, drafts: drafts, page: page)
  end

  def new(conn, _params) do
    last_issue =
      NewsIssue.published
      |> NewsIssue.newest_first
      |> Repo.one

    items =
      NewsItem.published_since(last_issue)
      |> NewsItem.newslettered
      |> NewsItem.newest_first
      |> Repo.all
      |> Enum.with_index(1)
      |> Enum.map(&NewsIssueItem.build_and_preload/1)

    changeset = NewsIssue.admin_changeset(%NewsIssue{news_issue_items: items})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"news_issue" => news_issue_params}) do
    changeset = NewsIssue.admin_changeset(%NewsIssue{}, news_issue_params)

    case Repo.insert(changeset) do
      {:ok, news_issue} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(news_issue, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    news_issue = NewsIssue |> Repo.get!(id) |> NewsIssue.preload_all()
    changeset = NewsIssue.admin_changeset(news_issue)
    render(conn, :edit, news_issue: news_issue, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_issue" => news_issue_params}) do
    news_issue = NewsIssue |> Repo.get!(id) |> NewsIssue.preload_all()
    changeset = NewsIssue.admin_changeset(news_issue, news_issue_params)

    case Repo.update(changeset) do
      {:ok, news_issue} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(news_issue, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, news_issue: news_issue, changeset: changeset)
    end
  end

  def publish(conn, %{"id" => id}) do
    news_issue = NewsIssue |> Repo.get!(id)
    changeset = Ecto.Changeset.change(news_issue, %{published: true, published_at: Timex.now})

    case Repo.update(changeset) do
      {:ok, _news_issue} ->
        conn
        |> put_flash(:result, "success")
        |> redirect(to: admin_news_issue_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, changeset: changeset)
    end
  end

  def unpublish(conn, %{"id" => id}) do
    news_issue = NewsIssue |> Repo.get!(id)
    changeset = Ecto.Changeset.change(news_issue, %{published: false, published_at: nil})

    case Repo.update(changeset) do
      {:ok, _news_issue} ->
        conn
        |> put_flash(:result, "success")
        |> redirect(to: admin_news_issue_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    news_issue = Repo.get!(NewsIssue, id)
    Repo.delete!(news_issue)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_issue_path(conn, :index))
  end

  defp smart_redirect(conn, _news_issue, %{"close" => _true}) do
    redirect(conn, to: admin_news_issue_path(conn, :index))
  end
  defp smart_redirect(conn, news_issue, _params) do
    redirect(conn, to: admin_news_issue_path(conn, :edit, news_issue))
  end
end
