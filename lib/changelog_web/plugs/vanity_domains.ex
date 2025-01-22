defmodule ChangelogWeb.Plug.VanityDomains do
  @moduledoc """
  Handles all redirects of podcast vanity domains to their appropriate place.
  """
  alias ChangelogWeb.PodcastView
  alias ChangelogWeb.RedirectController, as: Redirect
  import ChangelogWeb.Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    request_host = get_host(conn)
    main_host = ChangelogWeb.Endpoint.host()
    # short-circut because most requests will hit this
    if String.contains?("#{request_host}", "#{main_host}") do
      conn
      |> Plug.Conn.put_resp_header("x-changelog-vanity-redirect", "false")
    else
      Changelog.Cache.vanity_domains()
      |> Enum.reject(fn p -> is_nil(p.vanity_domain) end)
      |> Enum.find(fn p -> URI.parse(p.vanity_domain).host == request_host end)
      |> vanity_redirect(conn)
    end
  end

  # no-op if we didn't match a vanity domain
  defp vanity_redirect(nil, conn), do: conn

  defp vanity_redirect(podcast, conn = %{path_info: parts}) do
    destination = determine_destination(podcast, parts)

    conn
    |> Plug.Conn.put_resp_header("x-changelog-vanity-redirect", "true")
    |> Redirect.call(external: destination)
    |> Plug.Conn.halt()
  end

  defp determine_destination(%{slug: "podcast"}, ["sotl"]) do
    changelog_destination(["topic", "sotl"])
  end

  defp determine_destination(%{slug: "podcast"}, ["edu"]) do
    "https://changelog.fm/462"
  end

  # old news episode locations redirect
  ~w(2022-06-27 2022-07-04 2022-07-11 2022-07-18 2022-07-25 2022-08-01 2022-08-08
     2022-08-15 2022-08-22 2022-08-29 2022-09-05 2022-09-12 2022-09-19 2022-09-26
     2022-10-03 2022-10-10 2022-10-17 2022-10-24 2022-11-07 2022-11-14 2022-11-21
     2022-11-28 2022-12-05 2022-12-12 2023-01-02 2023-01-09 2023-01-16 2023-01-23
     2023-01-30 2023-02-06 2023-02-13 2023-02-20 2023-02-27 2023-03-06 2023-03-13
     2023-03-20 2023-03-27 2023-04-03)
  |> Enum.with_index()
  |> Enum.each(fn {date, index} ->
    defp determine_destination(%{slug: "podcast"}, ["news-" <> unquote(date)]) do
      changelog_destination(["news", unquote(index + 1)])
    end
  end)

  defp determine_destination(pod = %{slug: "gotime"}, ["gs"]) do
    determine_destination(pod, ["games"])
  end

  defp determine_destination(pod = %{slug: "jsparty"}, ["ff"]) do
    determine_destination(pod, ["games"])
  end

  defp determine_destination(podcast, parts) do
    # prevents infinite redirects back to vanity domain
    podcast = Map.delete(podcast, :vanity_domain)

    case parts do
      ["++"] -> Application.get_env(:changelog, :plusplus_url)
      ["apple"] -> PodcastView.subscribe_on_apple_url(podcast)
      ["android"] -> PodcastView.subscribe_on_android_url(podcast)
      ["spotify"] -> PodcastView.subscribe_on_spotify_url(podcast)
      ["youtube"] -> PodcastView.subscribe_on_youtube_url(podcast)
      ["overcast"] -> PodcastView.subscribe_on_overcast_url(podcast)
      ["pcast"] -> PodcastView.subscribe_on_pocket_casts_url(podcast)
      ["rss"] -> changelog_destination([podcast.slug, "feed"])
      ["email"] -> changelog_destination(["subscribe", podcast.slug])
      ["games"] -> changelog_destination(["topic", "games"])
      ["guest"] -> changelog_destination(["guest", podcast.slug])
      ["request"] -> changelog_destination(["request", podcast.slug])
      ["subscribe"] -> changelog_destination(["subscribe", podcast.slug])
      ["community"] -> changelog_destination(["community"])
      ["studio"] -> podcast.riverside_url
      ["merch"] -> "https://merch.changelog.com"
      _else -> changelog_destination([podcast.slug, parts])
    end
  end

  defp changelog_destination(parts) do
    path = parts |> List.flatten() |> Enum.join("/")
    "https://#{ChangelogWeb.Endpoint.host()}/#{path}"
  end
end
