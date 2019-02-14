defmodule ChangelogWeb.Admin.NewsSponsorshipControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.NewsSponsorship

  @valid_attrs %{name: "OHAI", sponsor_id: 1, weeks: ["2017-11-20"]}
  @invalid_attrs %{name: "", weeks: nil}

  @tag :as_admin
  test "lists all news sponsorships", %{conn: conn} do
    news_sponsorship = insert(:news_sponsorship)

    conn = get(conn, admin_news_sponsorship_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Sponsorships/
    assert String.contains?(conn.resp_body, news_sponsorship.name)
  end

  @tag :as_admin
  test "shows a specific sponsorship", %{conn: conn} do
    news_sponsorship = insert(:news_sponsorship)

    conn = get(conn, admin_news_sponsorship_path(conn, :show, news_sponsorship))

    assert html_response(conn, 200) =~ news_sponsorship.name
    assert String.contains?(conn.resp_body, news_sponsorship.sponsor.name)
  end

  @tag :as_admin
  test "lists the sponsorships on a schedule", %{conn: conn} do
    news_sponsorship = insert(:news_sponsorship, weeks: ["2017-11-20"])

    conn = get(conn, admin_news_sponsorship_path(conn, :schedule, year: "2017"))

    assert html_response(conn, 200) =~ ~r/Schedule/
    assert String.contains?(conn.resp_body, news_sponsorship.sponsor.name)
  end

  @tag :as_admin
  test "renders form to create new sponsorship", %{conn: conn} do
    conn = get(conn, admin_news_sponsorship_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates news sponsorship and redirects", %{conn: conn} do
    sponsor = insert(:sponsor)
    conn = post(conn, admin_news_sponsorship_path(conn, :create), news_sponsorship: %{@valid_attrs | sponsor_id: sponsor.id})

    created = Repo.one(NewsSponsorship.limit(1))
    assert redirected_to(conn) == admin_news_sponsorship_path(conn, :edit, created)
    assert count(NewsSponsorship) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(NewsSponsorship)
    conn = post(conn, admin_news_sponsorship_path(conn, :create), news_sponsorship: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsSponsorship) == count_before
  end

  @tag :as_admin
  test "renders form to edit news sponsorship", %{conn: conn} do
    news_sponsorship = insert(:news_sponsorship)

    conn = get(conn, admin_news_sponsorship_path(conn, :edit, news_sponsorship))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates news sponsorship and redirects", %{conn: conn} do
    sponsor = insert(:sponsor)
    news_sponsorship = insert(:news_sponsorship)
    conn = put(conn, admin_news_sponsorship_path(conn, :update, news_sponsorship.id), news_sponsorship: %{@valid_attrs | sponsor_id: sponsor.id})

    assert redirected_to(conn) == admin_news_sponsorship_path(conn, :index)
    assert count(NewsSponsorship) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    news_sponsorship = insert(:news_sponsorship)
    count_before = count(NewsSponsorship)

    conn = put(conn, admin_news_sponsorship_path(conn, :update, news_sponsorship.id), news_sponsorship: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(NewsSponsorship) == count_before
  end

  test "requires user auth on all actions", %{conn: conn} do
    news_sponsorship = insert(:news_sponsorship)

    Enum.each([
      get(conn, admin_news_sponsorship_path(conn, :index)),
      get(conn, admin_news_sponsorship_path(conn, :new)),
      post(conn, admin_news_sponsorship_path(conn, :create), news_sponsorship: @valid_attrs),
      get(conn, admin_news_sponsorship_path(conn, :edit, news_sponsorship.id)),
      put(conn, admin_news_sponsorship_path(conn, :update, news_sponsorship.id), news_sponsorship: @valid_attrs),
      delete(conn, admin_news_sponsorship_path(conn, :delete, news_sponsorship.id)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
