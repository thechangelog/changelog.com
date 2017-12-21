defmodule ChangelogWeb.Admin.NewsIssueController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsIssue, NewsItem, NewsIssueAd, NewsIssueItem, NewsSponsorship}

  plug :scrub_params, "news_issue" when action in [:create, :update]

  def index(conn, params) do
    page =
      NewsIssue.published
      |> order_by([s], desc: s.id)
      |> NewsIssue.preload_all
      |> Repo.paginate(params)

    drafts =
      NewsIssue.unpublished
      |> NewsIssue.newest_first(:inserted_at)
      |> Repo.all

    render(conn, :index, issues: page.entries, drafts: drafts, page: page)
  end

  def new(conn, _params) do
    last_issue =
      NewsIssue.published
      |> NewsIssue.newest_first
      |> NewsIssue.limit(1)
      |> Repo.one

    items =
      NewsItem.published_since(last_issue)
      |> NewsItem.newest_first
      |> Repo.all
      |> Enum.with_index(1)
      |> Enum.map(&NewsIssueItem.build_and_preload/1)

    ads =
      Timex.today
      |> NewsSponsorship.week_of
      |> NewsSponsorship.preload_all
      |> Repo.all
      |> Enum.map(&NewsSponsorship.ad_for_issue/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.with_index(1)
      |> Enum.map(&NewsIssueAd.build_and_preload/1)

    changeset = NewsIssue.admin_changeset(%NewsIssue{
      news_issue_items: items,
      news_issue_ads: ads,
      slug: NewsIssue.next_slug(last_issue)
    })

    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"news_issue" => issue_params}) do
    changeset = NewsIssue.admin_changeset(%NewsIssue{}, issue_params)

    case Repo.insert(changeset) do
      {:ok, issue} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(issue, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    issue = NewsIssue |> Repo.get!(id) |> NewsIssue.preload_all()
    changeset = NewsIssue.admin_changeset(issue)
    render(conn, :edit, issue: issue, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_issue" => issue_params}) do
    issue = NewsIssue |> Repo.get!(id) |> NewsIssue.preload_all()
    changeset = NewsIssue.admin_changeset(issue, issue_params)

    case Repo.update(changeset) do
      {:ok, issue} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(issue, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, issue: issue, changeset: changeset)
    end
  end

  def publish(conn, %{"id" => id}) do
    issue = NewsIssue |> Repo.get!(id)
    changeset = Ecto.Changeset.change(issue, %{published: true, published_at: Timex.now})

    case Repo.update(changeset) do
      {:ok, _issue} ->
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
    issue = NewsIssue |> Repo.get!(id)
    changeset = Ecto.Changeset.change(issue, %{published: false, published_at: nil})

    case Repo.update(changeset) do
      {:ok, _issue} ->
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
    issue = Repo.get!(NewsIssue, id)
    Repo.delete!(issue)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_issue_path(conn, :index))
  end

  defp smart_redirect(conn, _issue, %{"close" => _true}) do
    redirect(conn, to: admin_news_issue_path(conn, :index))
  end
  defp smart_redirect(conn, issue, _params) do
    redirect(conn, to: admin_news_issue_path(conn, :edit, issue))
  end
end
