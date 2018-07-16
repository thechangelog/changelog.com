defmodule ChangelogWeb.Admin.TopicControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Topic

  @valid_attrs %{name: "Ruby on Rails", slug: "ruby-on-rails"}
  @invalid_attrs %{name: "Ruby on Rails", slug: ""}

  @tag :as_admin
  test "lists all topics", %{conn: conn} do
    t1 = insert(:topic)
    t2 = insert(:topic)

    conn = get(conn, admin_topic_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Topics/
    assert String.contains?(conn.resp_body, t1.name)
    assert String.contains?(conn.resp_body, t2.name)
  end

  @tag :as_admin
  test "renders form to create new topic", %{conn: conn} do
    conn = get(conn, admin_topic_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates topic and redirects", %{conn: conn} do
    conn = post(conn, admin_topic_path(conn, :create), topic: @valid_attrs)

    created = Repo.one(Topic.limit(1))
    assert redirected_to(conn) == admin_topic_path(conn, :edit, created.slug)
    assert count(Topic) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Topic)
    conn = post(conn, admin_topic_path(conn, :create), topic: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Topic) == count_before
  end

  @tag :as_admin
  test "renders form to edit topic", %{conn: conn} do
    topic = insert(:topic)

    conn = get(conn, admin_topic_path(conn, :edit, topic.slug))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates topic and redirects", %{conn: conn} do
    topic = insert(:topic)

    conn = put(conn, admin_topic_path(conn, :update, topic.slug), topic: @valid_attrs)

    assert redirected_to(conn) == admin_topic_path(conn, :index)
    assert count(Topic) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    topic = insert(:topic)
    count_before = count(Topic)

    conn = put(conn, admin_topic_path(conn, :update, topic.slug), topic: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Topic) == count_before
  end

  test "requires user auth on all actions", %{conn: conn} do
    topic = insert(:topic)

    Enum.each([
      get(conn, admin_topic_path(conn, :index)),
      get(conn, admin_topic_path(conn, :new)),
      post(conn, admin_topic_path(conn, :create), topic: @valid_attrs),
      get(conn, admin_topic_path(conn, :edit, topic.slug)),
      put(conn, admin_topic_path(conn, :update, topic.slug), topic: @valid_attrs),
      delete(conn, admin_topic_path(conn, :delete, topic.slug)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
