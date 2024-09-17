defmodule ChangelogWeb.HomeView do
  use ChangelogWeb, :public_view

  alias Changelog.Podcast
  alias ChangelogWeb.{Home, PersonView, PodcastView}

  def cover_options(pods), do: Home.FeedView.cover_options(pods)

  def podcasts_with_subs(podcasts, user) do
    podcasts
    |> Enum.reject(&Podcast.is_news/1)
    |> Enum.filter(&Podcast.is_active/1)
    |> Enum.map(fn podcast ->
      Map.put(podcast, :is_subscribed, PersonView.is_subscribed(user, podcast))
    end)
  end

  def podcasts_with_newsletter_subs(podcasts, user) do
    podcasts
    |> Enum.filter(&Podcast.is_news/1)
    |> Enum.map(fn podcast ->
      Map.put(podcast, :is_subscribed, PersonView.is_subscribed(user, podcast))
    end)
  end

  def newsletter_link(newsletter, assigns) do
    id = newsletter.id

    cond do
      assigns.subscribed == id ->
        unsubscribe_link(assigns.conn, id)

      assigns.unsubscribed == id ->
        subscribe_link(assigns.conn, id)

      PersonView.is_subscribed(assigns.current_user, newsletter) ->
        unsubscribe_link(assigns.conn, id)

      true ->
        subscribe_link(assigns.conn, id)
    end
  end

  def subscribe_link(conn, id) do
    link("Subscribe", to: Routes.home_path(conn, :subscribe, id: id), method: :post)
  end

  def unsubscribe_link(conn, id) do
    link("Subscribed",
      to: Routes.home_path(conn, :unsubscribe, id: id),
      method: :post,
      class: "is-subscribed"
    )
  end
end
