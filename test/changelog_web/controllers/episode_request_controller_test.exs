defmodule ChangelogWeb.EpisodeRequestControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{EpisodeRequest}

  test "renders the form to request an episode", %{conn: conn} do
    conn = get(conn, Routes.episode_request_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/request/
  end

  test "does not create with no user", %{conn: conn} do
    count_before = count(EpisodeRequest)

    conn =
      post(conn, Routes.episode_request_path(conn, :create),
        episode_request: %{pitch: "this is gonna be good", podcast_id: 1}
      )

    assert redirected_to(conn) == Routes.sign_in_path(conn, :new)
    assert count(EpisodeRequest) == count_before
  end

  @tag :as_inserted_user
  test "creates request and sets it as fresh", %{conn: conn} do
    podcast = insert(:podcast)

    conn =
      post(conn, Routes.episode_request_path(conn, :create),
        episode_request: %{pitch: "pretty please!", podcast_id: podcast.id}
      )

    assert redirected_to(conn) == Routes.root_path(conn, :index)
    assert count(EpisodeRequest.fresh()) == 1
  end

  @tag :as_inserted_user
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(EpisodeRequest)
    conn = post(conn, Routes.episode_request_path(conn, :create), episode_request: %{})

    assert html_response(conn, 200) =~ ~r/error/
    assert count(EpisodeRequest) == count_before
  end

  @tag :as_admin
  test "declines an episode request and redirects", %{conn: conn} do
    request = insert(:episode_request)
    path = Routes.admin_podcast_episode_request_path(conn, :decline, request.podcast.slug, request.id)

    conn = put(conn, path)

    assert redirected_to(conn) ==
             Routes.admin_podcast_episode_request_path(conn, :index, request.podcast.slug)

    assert count(EpisodeRequest) == 1
    assert count(EpisodeRequest.declined()) == 1
  end

  @tag :as_admin
  test "declines an episode request with a message and redirects", %{conn: conn} do
    request = insert(:episode_request)
    path = Routes.admin_podcast_episode_request_path(conn, :decline, request.podcast.slug, request.id)

    conn = put(conn, path, %{"message" => "declined because reason"})

    assert redirected_to(conn) ==
             Routes.admin_podcast_episode_request_path(conn, :index, request.podcast.slug)

    assert count(EpisodeRequest) == 1
    assert count(EpisodeRequest.declined()) == 1

    assert %{message: "declined because reason", status: :declined} =
             Changelog.Repo.get(EpisodeRequest, request.id, [])
  end

  @tag :as_admin
  test "fails an episode request and redirects", %{conn: conn} do
    request = insert(:episode_request)
    path = Routes.admin_podcast_episode_request_path(conn, :fail, request.podcast.slug, request.id)

    conn = put(conn, path)

    assert redirected_to(conn) ==
             Routes.admin_podcast_episode_request_path(conn, :index, request.podcast.slug)

    assert count(EpisodeRequest) == 1
    assert count(EpisodeRequest.failed()) == 1
  end

  @tag :as_admin
  test "fails an episode request with a message and redirects", %{conn: conn} do
    request = insert(:episode_request)
    path = Routes.admin_podcast_episode_request_path(conn, :fail, request.podcast.slug, request.id)

    conn = put(conn, path, %{"message" => "failed because reason"})

    assert redirected_to(conn) ==
             Routes.admin_podcast_episode_request_path(conn, :index, request.podcast.slug)

    assert count(EpisodeRequest) == 1
    assert count(EpisodeRequest.failed()) == 1

    assert %{message: "failed because reason", status: :failed} =
             Changelog.Repo.get(EpisodeRequest, request.id, [])
  end
end
