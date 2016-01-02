defmodule Changelog.Admin.EpisodeControllerTest do
  use Changelog.ConnCase
  alias Changelog.Episode

  @valid_attrs %{title: "The one where we win"}
  @invalid_attrs %{title: ""}

  @tag :as_admin
  test "lists all podcast episodes on index", %{conn: conn} do
    p = create :podcast

    conn = get conn, admin_podcast_episode_path(conn, :index, p)

    assert html_response(conn, 200) =~ ~r/Episodes/
    assert String.contains?(conn.resp_body, p.name)
  end
end
