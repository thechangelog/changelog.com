defmodule ChangelogWeb.RedirectsTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.{Plug}

  def assert_redirect(conn, path_or_url, status \\ 302) do
    location = conn |> get_resp_header("location") |> List.first()
    assert conn.status == status

    cond do
      location == path_or_url ->
        assert true

      String.starts_with?(path_or_url, "http") ->
        assert location == path_or_url

      true ->
        assert location == "https://changelog.com#{path_or_url}"
    end
  end

  def build_conn_with_host_and_path(host, path) do
    build_conn(:get, path) |> put_req_header("host", host)
  end

  test "sponsor redirects for changelog.com host" do
    conn =
      build_conn_with_host_and_path("changelog.com", "/sentry")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "https://sentry.io/from/changelog/")
  end

  test "internal redirects for changelog.com host" do
    conn =
      build_conn_with_host_and_path("changelog.com", "/podcast/rss")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "/podcast/feed")
  end

  test "podcast redirects for changelog.com host" do
    conn =
      build_conn_with_host_and_path("changelog.com", "/1000?utm=yo")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "/podcast/1000?utm=yo")
  end

  test "domain redirects for 2020" do
    conn =
      build_conn_with_host_and_path("2020.changelog.com", "/jsparty/103")
      |> Plug.Redirects.call([])

    assert_redirect(conn, "https://changelog.com/jsparty/103", 301)
  end

  test "it no-ops for other hosts" do
    conn =
      :get
      |> build_conn("")
      |> Plug.Redirects.call([])

    assert conn.status != 302
  end
end
