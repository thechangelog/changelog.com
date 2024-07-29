defmodule ChangelogWeb.HomeFeedControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Feed

  @valid_attrs %{name: "My Custom Feed"}
  @invalid_attrs %{name: ""}

  @tag :as_inserted_member
  test "renders the index page with no feeds", %{conn: conn} do
    conn = get(conn, ~p"/~/feeds")
    assert html_response(conn, 200)
  end

  @tag :as_inserted_member
  test "renders the index page with feeds", %{conn: conn} do
    feed = insert(:feed, owner: conn.assigns.current_user)
    conn = get(conn, ~p"/~/feeds")
    assert html_response(conn, 200) =~ ~r/#{feed.name}/
  end

  @tag :as_inserted_member
  test "renders the new feed form", %{conn: conn} do
    conn = get(conn, ~p"/~/feeds/new")
    assert html_response(conn, 200) =~ "new"
  end

  @tag :as_inserted_member
  test "creates feed and redirects", %{conn: conn} do
    conn = post(conn, ~p"/~/feeds", feed: @valid_attrs)

    assert redirected_to(conn) == ~p"/~/feeds"
    assert count(Feed) == 1
  end

  @tag :as_inserted_member
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Feed)
    conn = post(conn, ~p"/~/feeds", feed: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Feed) == count_before
  end

  @tag :as_inserted_member
  test "renders form to edit feed", %{conn: conn} do
    feed = insert(:feed, owner: conn.assigns.current_user)

    conn = get(conn, ~p"/~/feeds/#{feed}/edit")
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_inserted_member
  test "updates feed and redirects", %{conn: conn} do
    feed = insert(:feed, owner: conn.assigns.current_user)

    conn = put(conn, ~p"/~/feeds/#{feed}", feed: @valid_attrs)

    assert redirected_to(conn) == ~p"/~/feeds"
    assert count(Feed) == 1
  end

  @tag :as_inserted_member
  test "does not update with invalid attributes", %{conn: conn} do
    feed = insert(:feed, owner: conn.assigns.current_user)

    conn = put(conn, ~p"/~/feeds/#{feed}", feed: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
  end

  test "requires user auth on all actions", %{conn: conn} do
    feed = insert(:feed)

    Enum.each(
      [
        get(conn, ~p"/~/feeds"),
        get(conn, ~p"/~/feeds/new"),
        post(conn, ~p"/~/feeds", feed: @valid_attrs),
        get(conn, ~p"/~/feeds/#{feed}/edit"),
        put(conn, ~p"/~/feeds/#{feed}", feed: @valid_attrs),
        delete(conn, ~p"/~/feeds/#{feed}")
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
