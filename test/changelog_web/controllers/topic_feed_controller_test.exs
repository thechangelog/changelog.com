defmodule ChangelogWeb.TopicFeedControllerTest do
  use ChangelogWeb.ConnCase

  # alias Changelog.NewsItem

  def valid_xml(conn) do
    SweetXml.parse(conn.resp_body)
    true
  end

  test "the topic of podcasts and news feed", %{conn: conn} do
  end

  test "the topic's news feed", %{conn: conn} do
  end

  test "the topic's podcasts feed", %{conn: conn} do
  end
end
