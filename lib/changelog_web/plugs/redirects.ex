defmodule ChangelogWeb.Plug.Redirects do
  @moduledoc """
  Handles all redirects, legacy and otherwise
  """
  use ChangelogWeb, :verified_routes

  alias ChangelogWeb.RedirectController, as: Redirect
  import ChangelogWeb.Plug.Conn

  @external %{
    "/sentry" => "https://sentry.io/from/changelog/",
    "/square" => "https://developer.squareup.com/",
    "/tailscale" =>
      "https://tailscale.com/?utm_source=sponsorship&utm_medium=podcast&utm_campaign=changelog&utm_term=changelog",
    "/reactpodcast" => "https://reactpodcast.simplecast.com",
    "/store" => "https://merch.changelog.com"
  }

  @internal %{
    "/rss" => "/feed",
    "/podcast/rss" => "/podcast/feed",
    "/feed.js" => "/feed",
    "/reactpodcast/feed" => "/jsparty/feed",
    "/team" => "/about",
    "/changeloggers" => "/about",
    "/membership" => "/++",
    "/sponsorship" => "/sponsor",
    "/soundcheck" => "/guest",
    "/submit" => "/news/submit",
    "/blog" => "/posts",
    "/weekly" => "/news",
    "/weekly/archive" => "/news",
    "/weekly/unsubscribed" => "/news"
  }

  def init(opts), do: opts

  def call(conn, _opts) do
    host = get_host(conn)
    default_host = ChangelogWeb.Endpoint.host()

    cond do
      String.contains?(host, "changelog.com") ->
        redirects(conn)

      String.contains?(host, default_host) ->
        redirects(conn)

      true ->
        conn
    end
  end

  defp redirects(conn) do
    conn
    |> internal_redirect()
    |> podcast_redirect()
    |> external_redirect()
  end

  defp internal_redirect(conn = %{halted: true}), do: conn

  defp internal_redirect(conn = %{request_path: path}) do
    if destination = Map.get(@internal, path, false) do
      conn |> Redirect.call(to: destination) |> Plug.Conn.halt()
    else
      conn
    end
  end

  defp podcast_redirect(conn = %{halted: true}), do: conn

  defp podcast_redirect(conn = %{request_path: path}) do
    if String.match?(path, ~r/\A\/\d+\z/) do
      conn |> Redirect.call(to: "/podcast" <> path) |> Plug.Conn.halt()
    else
      conn
    end
  end

  defp external_redirect(conn = %{halted: true}), do: conn

  defp external_redirect(conn = %{request_path: "/favicon.ico"}) do
    conn
    |> Redirect.call(external: url(~p"/favicon.ico"))
    |> Plug.Conn.halt()
  end

  defp external_redirect(conn = %{request_path: path}) do
    if destination = Map.get(@external, path, false) do
      conn |> Redirect.call(external: destination) |> Plug.Conn.halt()
    else
      conn
    end
  end
end
