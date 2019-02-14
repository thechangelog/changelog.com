defmodule ChangelogWeb.Admin.NewsIssueControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.NewsIssue

  @valid_attrs %{slug: "this-slug-is-niiiiice"}
  @invalid_attrs %{slug: nil}

  @tag :as_admin
  test "lists all news issues", %{conn: conn} do
    news_issue = insert(:news_issue)

    conn = get(conn, admin_news_issue_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Issues/
    assert String.contains?(conn.resp_body, news_issue.slug)
  end

  @tag :as_admin
  test "renders form to create new issue", %{conn: conn} do
    item = insert(:published_news_item)
    sponsorship = insert(:active_news_sponsorship)
    ad = insert(:news_ad, sponsorship: sponsorship)
    conn = get(conn, admin_news_issue_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
    assert String.contains?(conn.resp_body, item.headline)
    assert String.contains?(conn.resp_body, ad.headline)
  end

  @tag :as_admin
  test "creates news issue and redirects", %{conn: conn} do
    conn = post(conn, admin_news_issue_path(conn, :create), news_issue: @valid_attrs)

    assert redirected_to(conn) == admin_news_issue_path(conn, :index)
    assert count(NewsIssue) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(NewsIssue)
    conn = post(conn, admin_news_issue_path(conn, :create), news_issue: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsIssue) == count_before
  end

  @tag :as_admin
  test "renders form to edit news issue", %{conn: conn} do
    news_issue = insert(:news_issue)

    conn = get(conn, admin_news_issue_path(conn, :edit, news_issue))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates news issue and redirects", %{conn: conn} do
    news_issue = insert(:news_issue)
    conn = put(conn, admin_news_issue_path(conn, :update, news_issue.id), news_issue: @valid_attrs)

    assert redirected_to(conn) == admin_news_issue_path(conn, :index)
    assert count(NewsIssue) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    news_issue = insert(:news_issue)
    count_before = count(NewsIssue)

    conn = put(conn, admin_news_issue_path(conn, :update, news_issue.id), news_issue: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsIssue) == count_before
  end

  @tag :as_admin
  test "publishes a news issue", %{conn: conn} do
    news_issue = insert(:news_issue)

    conn = post(conn, admin_news_issue_path(conn, :publish, news_issue))

    assert redirected_to(conn) == admin_news_issue_path(conn, :index)
    assert count(NewsIssue.published) == 1
  end

  @tag :as_admin
  test "unpublishes a news issue", %{conn: conn} do
    news_issue = insert(:published_news_issue)

    conn = post(conn, admin_news_issue_path(conn, :unpublish, news_issue))

    assert redirected_to(conn) == admin_news_issue_path(conn, :index)
    assert count(NewsIssue.published) == 0
  end

  test "requires user auth on all actions", %{conn: conn} do
    news_issue = insert(:published_news_issue)

    Enum.each([
      get(conn, admin_news_issue_path(conn, :index)),
      get(conn, admin_news_issue_path(conn, :new)),
      post(conn, admin_news_issue_path(conn, :create), news_issue: @valid_attrs),
      get(conn, admin_news_issue_path(conn, :edit, news_issue.id)),
      put(conn, admin_news_issue_path(conn, :update, news_issue.id), news_issue: @valid_attrs),
      delete(conn, admin_news_issue_path(conn, :delete, news_issue.id)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
