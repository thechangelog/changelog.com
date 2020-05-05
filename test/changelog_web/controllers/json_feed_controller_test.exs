defmodule ChangelogWeb.JsonFeedControllerTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.Helpers.SharedHelpers

  test "the news feed", %{conn: conn} do
    post = insert(:published_post, body: "zomg")
    post_news_item = post |> post_news_item_with_story("**a story**") |> insert
    episode = insert(:published_episode, summary: "zomg")
    episode_news_item = episode |> episode_news_item_with_story("**a story**") |> insert
    news_item = insert(:published_news_item, story: "**a story**")

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> get(Routes.json_feed_path(conn, :news))

    assert conn.status == 200
    assert conn.resp_body =~ post.title
    assert conn.resp_body =~ episode.title
    assert conn.resp_body =~ news_item.headline
    assert conn.resp_body =~ SharedHelpers.md_to_text(post_news_item.story)
    assert conn.resp_body =~ SharedHelpers.md_to_text(episode_news_item.story)
    assert conn.resp_body =~ SharedHelpers.md_to_text(news_item.story)
  end
end
