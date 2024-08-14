defmodule ChangelogWeb.FeedController do
  use ChangelogWeb, :controller

  require Logger

  alias ChangelogWeb.Plug.ResponseCache
  alias ChangelogWeb.Xml

  plug ResponseCache

  def custom(conn, %{"slug" => slug}) do
    feed = ChangelogWeb.Feeds.generate(slug)
    send_xml_resp(conn, feed)
  end

  def news(conn, _params) do
    feed = ChangelogWeb.Feeds.generate("feed")
    send_xml_resp(conn, feed)
  end

  def podcast(conn, %{"slug" => "backstage"}) do
    send_resp(conn, :not_found, "")
  end

  def podcast(conn, %{"slug" => slug}) do
    feed = ChangelogWeb.Feeds.generate(slug)
    send_xml_resp(conn, feed)
  end

  def plusplus(conn, %{"slug" => slug}) do
    if Application.get_env(:changelog, :plusplus_slug) == slug do
      feed = ChangelogWeb.Feeds.generate("plusplus")
      send_xml_resp(conn, feed)
    else
      send_resp(conn, :not_found, "")
    end
  end

  def posts(conn, _params) do
    feed = ChangelogWeb.Feeds.generate("posts")
    send_xml_resp(conn, feed)
  end

  def sitemap(conn, _params) do
    sitemap = Xml.Sitemap.document() |> Xml.generate()

    conn
    |> ResponseCache.cache_public(:timer.minutes(3))
    |> send_xml_resp(sitemap)
  end

  defp send_xml_resp(conn, document) do
    conn
    |> put_layout(false)
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_content_type("application/xml")
    |> send_resp(200, document)
  end
end
