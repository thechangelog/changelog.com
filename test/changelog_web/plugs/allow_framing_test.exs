defmodule ChangelogWeb.AllowFramingTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.Plug

  test "removes frame-ancestors from CSP on embeds" do
    conn =
      build_conn(:get, "/founderstalk/62/embed")
      |> put_resp_header("content-security-policy", "base-uri 'self'; frame-ancestors 'self';")
      |> Plug.AllowFraming.call([])

    [csp] = get_resp_header(conn, "content-security-policy")
    refute csp =~ "frame-ancestors"
    assert csp =~ "base-uri 'self'"
  end

  test "does not modify CSP on other requests" do
    conn =
      build_conn(:get, "/founderstalk/62")
      |> put_resp_header("content-security-policy", "base-uri 'self'; frame-ancestors 'self';")
      |> Plug.AllowFraming.call([])

    assert get_resp_header(conn, "content-security-policy") == [
             "base-uri 'self'; frame-ancestors 'self';"
           ]
  end
end
