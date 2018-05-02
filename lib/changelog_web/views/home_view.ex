defmodule ChangelogWeb.HomeView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{Endpoint, PersonView, PodcastView}

  def newsletter_link(newsletter, assigns) do
    list = newsletter.list_id
    cond do
      assigns.subscribed == list -> unsubscribe_link(assigns.conn, list)
      assigns.unsubscribed == list -> subscribe_link(assigns.conn, list)
      PersonView.is_subscribed(assigns.current_user, newsletter) -> unsubscribe_link(assigns.conn, list)
      true -> subscribe_link(assigns.conn, list)
    end
  end

  def subscribe_link(conn, list) do
    link("Subscribe", to: home_path(conn, :subscribe, list), method: :post)
  end

  def unsubscribe_link(conn, list) do
    link("Subscribed", to: home_path(conn, :unsubscribe, list), method: :post, class: "is-subscribed")
  end
end
