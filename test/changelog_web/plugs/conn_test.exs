defmodule ChangelogWeb.ConnTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.Router
  alias ChangelogWeb.Plug.Conn

  setup _config do
    conn =
      build_conn()
      |> bypass_through(Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  describe "get_host/1" do
    test "no host set", %{conn: conn} do
      conn = Map.delete(conn, :host)
      assert Conn.get_host(conn) == ""
    end

    test "host set and forwarded header", %{conn: conn} do
      conn = put_req_header(conn, "x-forwarded-host", "better.com")
      conn = %Plug.Conn{conn | host: "changelog.com"}
      assert Conn.get_host(conn) == "better.com"
    end

    test "host with port", %{conn: conn} do
      conn = %Plug.Conn{conn | host: "changelog.com:443"}
      assert Conn.get_host(conn) == "changelog.com"
    end

    test "regular host", %{conn: conn} do
      conn = %Plug.Conn{conn | host: "changelog.com"}
      assert Conn.get_host(conn) == "changelog.com"
    end
  end

  describe "get_agent/1" do
    test "returns the user agent response header", %{conn: conn} do
      conn = put_req_header(conn, "user-agent", "Bond, James Bond")
      assert Conn.get_agent(conn) == "Bond, James Bond"
    end
  end

  describe "get_local_referer/1" do
    test "returns the refering path (not url) when its local", %{conn: conn} do
      referer = "https://www.example.com/my/path?test=1#anchor"
      conn = put_req_header(conn, "referer", referer)
      assert Conn.get_local_referer(conn) == "/my/path?test=1#anchor"
    end

    test "returns nil when referer is not local", %{conn: conn} do
      referer = "https://external.com/my/path"
      conn = put_req_header(conn, "referer", referer)
      assert is_nil(Conn.get_local_referer(conn))
    end
  end
end
