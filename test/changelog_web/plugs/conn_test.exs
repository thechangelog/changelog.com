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

  describe "get_encrypted_cookie/2" do
    test "is nil with invalid cookie", %{conn: conn} do
      assert Plug.Conn.get_encrypted_cookie(conn, "nope") == nil
    end

    test "is nil with valid cookie and invalid key", %{conn: conn} do
      conn = Plug.Conn.put_encrypted_cookie(conn, "test", "ahhh yisss")
      assert Plug.Conn.get_encrypted_cookie(conn, "nope") == nil
    end

    test "is nil when secret_key_base changes between calls", %{conn: conn} do
      conn = Plug.Conn.put_encrypted_cookie(conn, "test", "ahhh yisss")
      conn = Map.put(conn, :secret_key_base, "this is a new one")
      assert Plug.Conn.get_encrypted_cookie(conn, "test") == nil
    end

    test "gets value with valid cookie and key", %{conn: conn} do
      conn = Plug.Conn.put_encrypted_cookie(conn, "test", "ahhh yisss")
      assert Plug.Conn.get_encrypted_cookie(conn, "test") == "ahhh yisss"
    end
  end
end
