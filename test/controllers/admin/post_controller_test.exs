defmodule Changelog.Admin.PostControllerTest do
  use Changelog.ConnCase

  alias Changelog.Post

  @valid_attrs %{title: "Ruby on Rails", slug: "ruby-on-rails", author_id: 42}
  @invalid_attrs %{title: "Ruby on Rails", slug: "", author_id: 42}

  @tag :as_admin
  test "lists all posts", %{conn: conn} do
    t1 = create(:post)
    t2 = create(:post)

    conn = get conn, admin_post_path(conn, :index)

    assert html_response(conn, 200) =~ ~r/Posts/
    assert String.contains?(conn.resp_body, t1.title)
    assert String.contains?(conn.resp_body, t2.title)
  end

  @tag :as_admin
  test "renders form to create new post", %{conn: conn} do
    conn = get conn, admin_post_path(conn, :new)
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates post and redirects", %{conn: conn} do
    author = create(:person)
    conn = post conn, admin_post_path(conn, :create), post: %{@valid_attrs | author_id: author.id}

    assert redirected_to(conn) == admin_post_path(conn, :index)
    assert count(Post) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Post)
    conn = post conn, admin_post_path(conn, :create), post: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Post) == count_before
  end

  @tag :as_admin
  test "renders form to edit post", %{conn: conn} do
    post = create(:post)

    conn = get conn, admin_post_path(conn, :edit, post)
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates post and redirects", %{conn: conn} do
    author = create(:person)
    post = create(:post, author: author)

    conn = put conn, admin_post_path(conn, :update, post.id), post: %{@valid_attrs | author_id: author.id}

    assert redirected_to(conn) == admin_post_path(conn, :index)
    assert count(Post) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    post = create(:post)
    count_before = count(Post)

    conn = put conn, admin_post_path(conn, :update, post.id), post: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Post) == count_before
  end

  test "requires user auth on all actions" do
    Enum.each([
      get(conn, admin_post_path(conn, :index)),
      get(conn, admin_post_path(conn, :new)),
      post(conn, admin_post_path(conn, :create), post: @valid_attrs),
      get(conn, admin_post_path(conn, :edit, "123")),
      put(conn, admin_post_path(conn, :update, "123"), post: @valid_attrs),
      delete(conn, admin_post_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
