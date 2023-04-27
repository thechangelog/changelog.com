defmodule ChangelogWeb.RedirectsTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.Plug.Redirects

  @default_host ChangelogWeb.Endpoint.host()

  @changelog_hosts [
    @default_host,
    "#{@default_host}:4000",
    "changelog.com",
    "www.changelog.com",
    "2020.changelog.com",
    "21.changelog.com"
  ]

  @vanity_hosts [
    "changelog.fm",
    "gotime.fm",
    "jsparty.fm"
  ]

  @redirects [
    [
      path: "/sentry",
      location: "https://sentry.io/from/changelog/"
    ],
    [
      path: "/1000?utm=yo",
      location: "/podcast/1000?utm=yo"
    ],
    [
      path: "/rss",
      location: "/feed"
    ]
  ]

  def assert_redirect(conn, path_or_url, status \\ 302) do
    location = conn |> get_resp_header("location") |> List.first()
    assert conn.status == status, "Expected #{status} #{location}, got #{conn.status} instead"

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

  def http_conn(host, path) do
    conn = build_conn(:get, path)
    conn = %Plug.Conn{conn | host: host}

    Redirects.call(conn, [])
  end

  test "changelog hosts" do
    for redirect <- @redirects do
      [path: path, location: location] = redirect

      for host <- @changelog_hosts do
        assert_redirect(http_conn(host, path), location)
      end
    end
  end

  test "vanity hosts" do
    for redirect <- @redirects do
      [path: path, location: _] = redirect

      for host <- @vanity_hosts do
        assert_redirect(http_conn(host, path), nil, nil)
      end
    end
  end
end
