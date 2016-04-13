defmodule Changelog.PodcastControllerTest do
  use Changelog.ConnCase

  test "getting a podcast page" do
    p = create :podcast
    conn = get conn, podcast_path(conn, :show, p.slug)
    assert html_response(conn, 200) =~ p.name
  end

  test "getting a podcast page with a published episode" do
    p = create :podcast
    e = create :episode, podcast: p, published: true
    conn = get conn, podcast_path(conn, :show, p.slug)
    assert html_response(conn, 200) =~ p.name
    assert String.contains?(conn.resp_body, e.title)
  end

  test "getting a podcast page that doesn't exist" do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, podcast_path(conn, :show, "bad-show")
    end
  end

  test "getting a published podcast episode page" do
    p = create :podcast
    e = create :episode, podcast: p, published: true
    conn = get conn, episode_path(conn, :episode, p.slug, e.slug)
    assert html_response(conn, 200) =~ e.title
  end

  test "getting a podcast episode page that is not published" do
    p = create :podcast
    e = create :episode, podcast: p, published: false

    assert_raise Ecto.NoResultsError, fn ->
      get conn, episode_path(conn, :episode, p.slug, e.slug)
    end
  end

  test "geting a podcast episode page that doesn't exist" do
    p = create :podcast

    assert_raise Ecto.NoResultsError, fn ->
      get conn, episode_path(conn, :episode, p.slug, "bad-episode")
    end
  end
end
