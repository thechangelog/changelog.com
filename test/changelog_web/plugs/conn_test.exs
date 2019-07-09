defmodule ChangelogWeb.ConnTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.{Plug, Router}

  setup _config do
    conn =
      build_conn()
      |> bypass_through(Router, :browser)
      |> get("/")
    {:ok, %{conn: conn}}
  end

  describe "get_agent/1" do
    test "returns the user agent response header", %{conn: conn} do
      conn = put_req_header(conn, "user-agent", "Bond, James Bond")
      assert Plug.Conn.get_agent(conn) == "Bond, James Bond"
    end
  end
end
