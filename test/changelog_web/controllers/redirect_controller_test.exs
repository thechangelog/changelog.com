defmodule ChangelogWeb.RedirectorTest do
  use ExUnit.Case, async: true

  alias ChangelogWeb.RedirectController, as: Redirector

  defmodule Router do
    use Phoenix.Router

    get "/tatooine", Redirector, to: "/alderaan"
    get "/exceptional", Redirector, []
    get "/bespin", Redirector, external: "https://duckduckgo.com/"
    get "/hoth", Redirector, external: "https://duckduckgo.com/?q=hoth&ia=images&iax=1"
  end

  test "an exception is raised when `to` or `external` isn't defined" do
    assert_raise Plug.Conn.WrapperError,
                 ~r[Missing required to: / external: option in redirect],
                 fn ->
                   call(Router, :get, "/exceptional")
                 end
  end

  test "route redirected to internal route" do
    conn = call(Router, :get, "/tatooine")

    assert_redirected_to(conn, "/alderaan")
  end

  test "route redirected to internal route with query string" do
    conn = call(Router, :get, "/tatooine?gtm_a=starports")

    assert_redirected_to(conn, "/alderaan?gtm_a=starports")
  end

  test "route redirected to external route" do
    conn = call(Router, :get, "/bespin")

    assert_redirected_to(conn, "https://duckduckgo.com/")
  end

  test "route redirected to external route with query string" do
    conn = call(Router, :get, "/bespin?q=bespin")

    assert_redirected_to(conn, "https://duckduckgo.com/?q=bespin")
  end

  test "route redirected to external route merges query string" do
    conn = call(Router, :get, "/hoth?q=endor")

    assert_redirected_to(conn, "https://duckduckgo.com/?q=endor&ia=images&iax=1")
  end

  defp call(router, verb, path) do
    verb
    |> Plug.Test.conn(path)
    |> router.call(router.init([]))
  end

  defp assert_redirected_to(conn, expected_url) do
    actual_uri =
      conn
      |> Plug.Conn.get_resp_header("location")
      |> List.first()
      |> URI.parse()

    expected_uri = URI.parse(expected_url)

    assert conn.status == 302
    assert actual_uri.scheme == expected_uri.scheme
    assert actual_uri.host == expected_uri.host
    assert actual_uri.path == expected_uri.path

    if actual_uri.query do
      assert Map.equal?(URI.decode_query(actual_uri.query), URI.decode_query(expected_uri.query))
    end
  end
end
