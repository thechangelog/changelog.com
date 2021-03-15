defmodule ChangelogWeb.Admin.NewsItemSubscriptionController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, Subscription}

  plug :assign_item
  plug Authorize, [Policies.Admin.Subscription, :item]

  def index(conn = %{assigns: %{item: item}}, params) do
    page =
      Subscription.on_item(item)
      |> Subscription.newest_first()
      |> Subscription.preload_person()
      |> Repo.paginate(params)

    conn
    |> assign(:subscriptions, page.entries)
    |> assign(:page, page)
    |> render(:index)
  end

  defp assign_item(conn = %{params: %{"news_item_id" => id}}, _) do
    item = NewsItem |> Repo.get!(id) |> NewsItem.preload_all()
    assign(conn, :item, item)
  end
end
