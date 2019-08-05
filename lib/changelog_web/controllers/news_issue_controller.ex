defmodule ChangelogWeb.NewsIssueController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsIssue, NewsItem}

  plug :put_layout, false

  def show(conn, %{"id" => slug}) do
    issue =
      NewsIssue.published()
      |> NewsIssue.preload_all()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:issue, issue)
    |> assign(:ads, ads_for_issue(issue))
    |> assign(:items, items_for_issue(issue))
    |> render(template_for_issue(issue))
  end

  def preview(conn, %{"id" => slug}) do
    issue =
      NewsIssue.unpublished()
      |> NewsIssue.preload_all()
      |> Repo.get_by!(slug: slug)

    conn
    |> assign(:issue, issue)
    |> assign(:ads, ads_for_issue(issue))
    |> assign(:items, items_for_issue(issue))
    |> render(template_for_issue(issue))
  end

  defp ads_for_issue(issue) do
    issue
    |> Map.get(:news_issue_ads)
    |> Enum.map(fn(a) -> apply_image_setting(a.ad, a.image) end)
  end

  defp items_for_issue(issue) do
    issue
    |> Map.get(:news_issue_items)
    |> Enum.map(fn(i) -> apply_image_setting(i.item, i.image) end)
    |> Enum.map(&NewsItem.load_object/1)
  end

  defp apply_image_setting(item_or_ad, true), do: item_or_ad
  defp apply_image_setting(item_or_ad, false), do: Map.put(item_or_ad, :image, false)

  defp template_for_issue(issue) do
    String.to_atom("show_#{NewsIssue.layout(issue)}")
  end
end
