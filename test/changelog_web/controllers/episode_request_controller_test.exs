defmodule ChangelogWeb.EpisodeRequestControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{EpisodeRequest}

  test "renders the form to request an episode", %{conn: conn} do
    conn = get(conn, episode_request_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/request/
  end

  test "does not create with no user", %{conn: conn} do
    count_before = count(EpisodeRequest)
    conn = post(conn, episode_request_path(conn, :create), episode_request: %{pitch: "this is gonna be good", podcast_id: 1})

    assert redirected_to(conn) == sign_in_path(conn, :new)
    assert count(EpisodeRequest) == count_before
  end

  @tag :as_inserted_user
  test "creates request and sets it as submitted", %{conn: conn} do
    podcast = insert(:podcast)
    conn = post(conn, episode_request_path(conn, :create), episode_request: %{pitch: "pretty please!", podcast_id: podcast.id})

    assert redirected_to(conn) == root_path(conn, :index)
    assert count(EpisodeRequest.submitted) == 1
  end

  @tag :as_inserted_user
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(EpisodeRequest)
    conn = post(conn, episode_request_path(conn, :create), episode_request: %{})

    assert html_response(conn, 200) =~ ~r/error/
    assert count(EpisodeRequest) == count_before
  end
end
