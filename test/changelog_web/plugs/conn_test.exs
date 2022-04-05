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

  describe "get_host/1" do
    test "no host header", %{conn: conn} do
      assert Plug.Conn.get_host(conn) == ""
    end

    test "host header and forwarded header", %{conn: conn} do
      conn = put_req_header(conn, "x-forwarded-host", "better.com")
      conn = put_req_header(conn, "host", "changelog.com")
      assert Plug.Conn.get_host(conn) == "better.com"
    end

    test "host with port", %{conn: conn} do
      conn = put_req_header(conn, "host", "changelog.com:443")
      assert Plug.Conn.get_host(conn) == "changelog.com"
    end

    test "regular host", %{conn: conn} do
      conn = put_req_header(conn, "host", "changelog.com")
      assert Plug.Conn.get_host(conn) == "changelog.com"
    end
  end

  describe "get_agent/1" do
    test "returns the user agent response header", %{conn: conn} do
      conn = put_req_header(conn, "user-agent", "Bond, James Bond")
      assert Plug.Conn.get_agent(conn) == "Bond, James Bond"
    end
  end

  describe "get_local_referer/1" do
    test "returns the refering path (not url) when its local", %{conn: conn} do
      referer = "https://www.example.com/my/path?test=1#anchor"
      conn = put_req_header(conn, "referer", referer)
      assert Plug.Conn.get_local_referer(conn) == "/my/path?test=1#anchor"
    end

    test "returns nil when referer is not local", %{conn: conn} do
      referer = "https://external.com/my/path"
      conn = put_req_header(conn, "referer", referer)
      assert is_nil(Plug.Conn.get_local_referer(conn))
    end
  end
end
