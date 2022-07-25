defmodule ChangelogWeb.Plug.VanityDomains do
  @moduledoc """
  Handles all redirects of podcast vanity domains to their appropriate place.
  """
  alias ChangelogWeb.PodcastView
  alias ChangelogWeb.RedirectController, as: Redirect
  import ChangelogWeb.Plug.Conn

  def init(opts), do: opts

  # should be called after the LoadPodcasts plug for data access
  def call(conn = %{assigns: %{podcasts: podcasts}}, _opts) do
    request_host = get_host(conn)
    main_host = ChangelogWeb.Endpoint.host()
    # short-circut because most requests will hit this
    if String.contains?("#{request_host}", "#{main_host}") do
      conn
      |> Plug.Conn.put_resp_header("x-changelog-vanity-redirect", "false")
    else
      podcasts
      |> Enum.reject(fn p -> is_nil(p.vanity_domain) end)
      |> Enum.find(fn p -> URI.parse(p.vanity_domain).host == request_host end)
      |> vanity_redirect(conn)
    end
  end

  # no-op if we don't have any podcasts in assigns
  def call(conn, _opts), do: conn

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
    "https://changelog.fm/473"
  end
  defp determine_destination(%{slug: "podcast"}, ["edu"]) do
    "https://changelog.fm/462"
  end
  defp determine_destination(%{slug: "gotime"}, ["gs"]) do
    "https://changelog.typeform.com/to/IR4twWc6"
  end
  defp determine_destination(%{slug: "jsparty"}, ["ff"]) do
    "https://changelog.typeform.com/to/WWOhHlmL"
  end

  defp determine_destination(podcast, parts) do
    # prevents infinite redirects back to vanity domain
    podcast = Map.delete(podcast, :vanity_domain)

    case parts do
      ["++"] -> Application.get_env(:changelog, :plusplus_url)
      ["apple"] -> PodcastView.subscribe_on_apple_url(podcast)
      ["android"] -> PodcastView.subscribe_on_android_url(podcast)
      ["spotify"] -> PodcastView.subscribe_on_spotify_url(podcast)
      ["overcast"] -> PodcastView.subscribe_on_overcast_url(podcast)
      ["rss"] -> changelog_destination([podcast.slug, "feed"])
      ["email"] -> changelog_destination(["subscribe", podcast.slug])
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
