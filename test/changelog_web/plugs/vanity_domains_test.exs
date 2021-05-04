defmodule ChangelogWeb.VanityDomainsTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.{Plug}

  @jsparty %{
    vanity_domain: "https://jsparty.fm",
    slug: "jsparty",
    apple_url: "https://podcasts.apple.com/us/podcast/js-party/id1209616598",
    name: "JS Party"
  }
  @gotime %{
    vanity_domain: "https://gotime.fm",
    slug: "gotime",
    spotify_url: "https://spotify.com",
    name: "Go Time"
  }

  def assert_vanity_redirect(conn, path_or_url) do
    location = conn |> get_resp_header("location") |> List.first()
    assert conn.status == 302

    if String.starts_with?(path_or_url, "http") do
      assert location == path_or_url
    else
      assert location == "https://#{ChangelogWeb.Endpoint.host()}#{path_or_url}"
    end
  end

  def build_conn_with_host_and_path(host, path) do
    build_conn(:get, path) |> put_req_header("host", host)
  end

  def assign_podcasts(conn, podcasts) do
    assign(conn, :podcasts, podcasts)
  end

  test "vanity redirects for root path" do
    conn =
      build_conn_with_host_and_path("jsparty.fm", "/")
      |> assign_podcasts([@jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "/jsparty")
  end

  test "vanity redirects for episode sub-paths" do
    conn =
      build_conn_with_host_and_path("gotime.fm", "/102")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "/gotime/102")
  end

  test "vanity redirects for apple URL" do
    conn =
      build_conn_with_host_and_path("jsparty.fm", "/apple")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, @jsparty.apple_url)
  end

  test "vanity redirects for spotify URL" do
    conn =
      build_conn_with_host_and_path("gotime.fm", "/spotify")
      |> assign_podcasts([@gotime, @gotime])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, @gotime.spotify_url)
  end

  test "vanity redirects for overcast URL" do
    conn =
      build_conn_with_host_and_path("jsparty.fm", "/overcast")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "https://overcast.fm/itunes1209616598/js-party")
  end

  test "vanity redirects for RSS URL" do
    conn =
      build_conn_with_host_and_path("gotime.fm", "/rss")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "/gotime/feed")
  end

  test "vanity redirects for email URL" do
    conn =
      build_conn_with_host_and_path("jsparty.fm", "/email")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "/subscribe/jsparty")
  end

  test "vanity redirects for request URL" do
    conn =
      build_conn_with_host_and_path("gotime.fm", "/request")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "/request/gotime")
  end

  test "vanity redirects for community URL" do
    conn =
      build_conn_with_host_and_path("jsparty.fm", "/community")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "/community")
  end

  test "vanity redirects for jsparty ff form" do
    conn =
      build_conn_with_host_and_path("jsparty.fm", "/ff")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    assert_vanity_redirect(conn, "https://changelog.typeform.com/to/wTCcQHGQ")
  end

  test "it does not vanity redirect for default host" do
    conn =
      build_conn_with_host_and_path(ChangelogWeb.Endpoint.host(), "/")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    vanity_redirect = conn |> get_resp_header("x-changelog-vanity-redirect")
    assert vanity_redirect == ["false"]
  end

  test "it does not vanity redirect for default host subdomain" do
    conn =
      build_conn_with_host_and_path("21.#{ChangelogWeb.Endpoint.host()}", "/")
      |> assign_podcasts([@gotime, @jsparty])
      |> Plug.VanityDomains.call([])

    vanity_redirect = conn |> get_resp_header("x-changelog-vanity-redirect")
    assert vanity_redirect == ["false"]
  end

  test "it no-ops for other hosts" do
    conn =
      :get
      |> build_conn("")
      |> Plug.VanityDomains.call([])

    assert conn.status == nil
  end
end
