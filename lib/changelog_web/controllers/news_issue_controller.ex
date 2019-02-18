defmodule ChangelogWeb.NewsIssueController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsIssue, NewsItem}

  plug :put_layout, false

  def show(conn, %{"id" => slug}) do
    issue =
      NewsIssue.published()
      |> Repo.get_by!(slug: slug)
      |> NewsIssue.preload_all()

    ads = issue.ads
    items = Enum.map(issue.items, &NewsItem.load_object/1)

    conn
    |> assign(:issue, issue)
    |> assign(:ads, ads)
    |> assign(:items, items)
    |> render(:show)
  end

  def preview(conn, %{"id" => slug}) do
    issue =
      NewsIssue
      |> Repo.get_by!(slug: slug)
      |> NewsIssue.preload_all()

    ads = issue.ads
    items = Enum.map(issue.items, &NewsItem.load_object/1)

    conn
    |> assign(:issue, issue)
    |> assign(:ads, ads)
    |> assign(:items, items)
    |> render(:show)
  end
end
