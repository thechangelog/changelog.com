defmodule ChangelogWeb.SponsorControllerTest do
  use ChangelogWeb.ConnCase

  test "/sponsor", %{conn: conn} do
    conn = get(conn, ~p"/sponsor")
    assert conn.status == 200
  end

  test "/sponsor/pricing", %{conn: conn} do
    conn = get(conn, ~p"/sponsor/pricing")
    assert conn.status == 200
  end

  test "/sponsor/styles", %{conn: conn} do
    conn = get(conn, ~p"/sponsor/styles")
    assert conn.status == 200
  end

  describe "sponsor stories" do
    test "it renders for all known sponsor stories", %{conn: conn} do
      for story <- Changelog.SponsorStory.all() do
        conn = get(conn, ~p"/sponsor/stories/#{story.slug}")
        assert html_response(conn, 200) =~ story.sponsor
      end
    end

    test "it falls back to the rollbar story", %{conn: conn} do
      conn = get(conn, ~p"/sponsor/stories/ohai")
      assert html_response(conn, 200) =~ "Rollbar"
    end
  end
end
