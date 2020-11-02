defmodule ChangelogWeb.Plug.Redirects do
  @moduledoc """
  Handles all redirects, legacy and otherwise
  """
  alias ChangelogWeb.RedirectController, as: Redirect
  import ChangelogWeb.Plug.Conn

  @sponsors %{
    "/datadog" =>
      "https://www.datadoghq.com/lpgs/?utm_source=Advertisement&utm_medium=Advertisement&utm_campaign=ChangelogPodcast-Tshirt",
    "/sentry" => "https://sentry.io/from/changelog/",
    "/codacy" =>
      "https://codacy.com/product?utm_source=Changelog&utm_medium=cpm&utm_campaign=Changelog-Podcast"
  }

  @internal %{
    "/rss" => "/feed",
    "/podcast/rss" => "/podcast/feed",
    "/team" => "/about",
    "/changeloggers" => "/about",
    "/membership" => "/community",
    "/store" => "/community",
    "/sponsorship" => "/sponsor",
    "/soundcheck" => "/guest",
    "/submit" => "/news/submit",
    "blog" => "/posts"
  }

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_host(conn) do
      "changelog.com" -> changelog_redirects(conn)
      "2020.changelog.com" -> domain_redirects(conn)
      "www.changelog.com" -> domain_redirects(conn)
      _else -> conn
    end
  end

  defp changelog_redirects(conn) do
    conn
    |> internal_redirect()
    |> podcast_redirect()
    |> sponsor_redirect()
  end

  defp domain_redirects(conn = %{request_path: path}) do
    conn
    |> Plug.Conn.put_status(301)
    |> Redirect.call(external: "https://changelog.com" <> path)
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

  defp sponsor_redirect(conn = %{halted: true}), do: conn

  defp sponsor_redirect(conn = %{request_path: path}) do
    if destination = Map.get(@sponsors, path, false) do
      conn |> Redirect.call(external: destination) |> Plug.Conn.halt()
    else
      conn
    end
  end
end
