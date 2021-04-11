defmodule ChangelogWeb.Plug.VanityDomains do
  @moduledoc """
  Handles all redirects of podcast vanity domains to their appropriate place.
  """
  alias ChangelogWeb.PodcastView
  alias ChangelogWeb.RedirectController, as: Redirect
  import ChangelogWeb.Plug.Conn

  require Logger

  def init(opts), do: opts

  # should be called after the LoadPodcasts plug for data access
  def call(conn = %{assigns: %{podcasts: podcasts}}, _opts) do
    host = get_host(conn)
    # short-circut because most requests will hit this
    if host == ChangelogWeb.Endpoint.host do
      conn
    else
      Logger.info("Vanity Redirect: #{host}#{conn.request_path}")

      podcasts
      |> Enum.reject(fn p -> is_nil(p.vanity_domain) end)
      |> Enum.find(fn p -> URI.parse(p.vanity_domain).host == host end)
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
    |> Redirect.call(external: destination)
    |> Plug.Conn.halt()
  end

  defp determine_destination(%{slug: "jsparty"}, ["ff"]) do
    "https://changelog.typeform.com/to/wTCcQHGQ"
  end

  defp determine_destination(podcast, parts) do
    case parts do
      ["apple"] -> podcast.apple_url
      ["android"] -> PodcastView.subscribe_on_android_url(podcast)
      ["spotify"] -> podcast.spotify_url
      ["overcast"] -> PodcastView.subscribe_on_overcast_url(podcast)
      ["rss"] -> changelog_destination([podcast.slug, "feed"])
      ["email"] -> changelog_destination(["subscribe", podcast.slug])
      ["request"] -> changelog_destination(["request", podcast.slug])
      ["subscribe"] -> changelog_destination(["subscribe", podcast.slug])
      _else -> changelog_destination([podcast.slug, parts])
    end
  end

  defp changelog_destination(parts) do
    path = parts |> List.flatten() |> Enum.join("/")
    "https://#{ChangelogWeb.Endpoint.host}/#{path}"
  end
end
