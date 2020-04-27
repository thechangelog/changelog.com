defmodule ChangelogWeb.HomeView do
  use ChangelogWeb, :public_view

  import ChangelogWeb.PersonView, only: [avatar_url: 1, is_subscribed: 2]
  alias ChangelogWeb.{PodcastView}

  def newsletter_link(newsletter, assigns) do
    list = newsletter.list_id
    cond do
      assigns.subscribed == list -> unsubscribe_link(assigns.conn, list)
      assigns.unsubscribed == list -> subscribe_link(assigns.conn, list)
      is_subscribed(assigns.current_user, newsletter) -> unsubscribe_link(assigns.conn, list)
      true -> subscribe_link(assigns.conn, list)
    end
  end

  def subscribe_link(conn, list) do
    link("Subscribe", to: Routes.home_path(conn, :subscribe, id: list), method: :post)
  end

  def unsubscribe_link(conn, list) do
    link("Subscribed", to: Routes.home_path(conn, :unsubscribe, id: list), method: :post, class: "is-subscribed")
  end
end
