defmodule ChangelogWeb.RedirectsTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.{Plug}

  def assert_redirect(conn, path_or_url, status \\ 302) do
    location = conn |> get_resp_header("location") |> List.first()
    assert conn.status == status

    cache_control = conn |> get_resp_header("cache-control")
    assert cache_control == ["max-age=0, private, must-revalidate"]

    surrogate_control = conn |> get_resp_header("surrogate-control")
    assert surrogate_control == []

    cond do
      location == path_or_url ->
        assert true

      String.starts_with?(path_or_url, "http") ->
        assert location == path_or_url

      true ->
        assert location == "https://#{ChangelogWeb.Endpoint.host()}#{path_or_url}"
    end
  end

  def build_conn_with_host_and_path(host, path) do
    build_conn(:get, path) |> put_req_header("host", host)
  end

  test "sponsor redirects for default host" do
    conn =
      build_conn_with_host_and_path(ChangelogWeb.Endpoint.host(), "/sentry")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "https://sentry.io/from/changelog/")
  end

  test "internal redirects for default host" do
    conn =
      build_conn_with_host_and_path(ChangelogWeb.Endpoint.host(), "/podcast/rss")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "/podcast/feed")
  end

  test "podcast redirects for default host" do
    conn =
      build_conn_with_host_and_path(ChangelogWeb.Endpoint.host(), "/1000?utm=yo")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "/podcast/1000?utm=yo")
  end

  test "it no-ops for other hosts" do
    conn =
      :get
      |> build_conn("")
      |> Plug.Redirects.call([])

    assert conn.status != 302
  end

  test "www redirects" do
    conn =
      build_conn_with_host_and_path("www.changelog.com", "/")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "https://#{ChangelogWeb.Endpoint.host()}/", 301)
  end

  test "podcast redirects for www" do
    conn =
      build_conn_with_host_and_path("www.changelog.com", "/jsparty/103")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "https://#{ChangelogWeb.Endpoint.host()}/jsparty/103", 301)
  end
end
