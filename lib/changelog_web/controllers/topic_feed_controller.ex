defmodule ChangelogWeb.TopicFeedController do
  @moduledoc"""
  Provides rss feed content for specific topics on changelog.com
  """
  use ChangelogWeb, :controller

  require Logger

  alias Changelog.{ NewsItem, NewsSource, Podcast, Topic }
  alias ChangelogWeb.Plug.ResponseCache

  # plug :log_subscribers, "log podcast subscribers" when action in [:podcast]
  plug ResponseCache

  @doc "Latest news and podcasts feed"
  def topic(_conn, _params) do
    # TODO
  end

  @doc "Only news feed"
  def news(conn, params =%{"slug" => slug}) do
    topic = Repo.get_by!(Topic, slug: slug)

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> assign(:items, NewsItem.latest_news_items())
    |> ResponseCache.cache_public(cache_duration())
    |> render("#{slug} news.xml")
  end

  @doc "Only podcasts feed"
  def podcasts(_conn, _params) do
    # TODO: import render for podcast

    # render_for_podcast(conn, podcast)
  end

  # TODO: abstract away repetition
  defp cache_duration, do: 2..10 |> Enum.random() |> :timer.minutes()
end
