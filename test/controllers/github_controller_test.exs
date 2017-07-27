defmodule Changelog.GithubControllerTest do
  use Changelog.ConnCase

  # import Mock

  describe "the event endpoint" do
    setup do
      conn = put_req_header(build_conn(), "accept", "application/json")
      {:ok, conn: conn}
    end

    test "it responds to the push event", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-github-event", "push")
        |> post(github_path(conn, :event, %{}))

      assert conn.status == 200
    end

    test "it responds with method not allowed for unsupported events", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-github-event", "milestone")
        |> post(github_path(conn, :event, %{}))

      assert conn.status == 405
    end
  end
end
