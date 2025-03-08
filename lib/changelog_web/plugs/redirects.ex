defmodule ChangelogWeb.Plug.Redirects do
  @moduledoc """
  Handles all redirects, legacy and otherwise
  """
  use ChangelogWeb, :verified_routes

  alias ChangelogWeb.RedirectController, as: Redirect
  import ChangelogWeb.Plug.Conn

  @external [
    {"/sentry", "https://sentry.io/from/changelog/", 302},
    {"/square", "https://developer.squareup.com/", 302},
    {"/tailscale",
     "https://tailscale.com/?utm_source=sponsorship&utm_medium=podcast&utm_campaign=changelog&utm_term=changelog",
     302},
    {"/reactpodcast", "https://reactpodcast.simplecast.com", 301},
    {"/store", "https://merch.changelog.com", 302},
    {"/practicalai", "https://practicalai.fm", 301},
    {"/practicalai/feed",
     "https://feeds.transistor.fm/practical-ai-machine-learning-data-science-llm", 301},
    {~r/\A\/practicalai\/(\d+)\z/, "https://practicalai.fm/*", 301}
  ]

  @internal [
    {"/rss", "/feed", 301},
    {"/podcast/rss", "/podcast/feed", 301},
    {"/feed.js", "/feed", 301},
    {"/reactpodcast/feed", "/jsparty/feed", 301},
    {"/team", "/about", 302},
    {"/changeloggers", "/about", 302},
    {"/membership", "/++", 302},
    {"/sponsorship", "/sponsor", 302},
    {"/soundcheck", "/guest", 302},
    {"/submit", "/news/submit", 302},
    {"/blog", "/posts", 302},
    {"/weekly", "/news", 302},
    {"/weekly/archive", "/news", 302},
    {"/weekly/unsubscribed", "/news", 302}
  ]

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
    case Enum.find_value(@internal, &determine_destination(&1, path)) do
      {destination, type} ->
        conn
        |> Plug.Conn.put_status(type)
        |> Redirect.call(to: destination)
        |> Plug.Conn.halt()

      nil ->
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
    case Enum.find_value(@external, &determine_destination(&1, path)) do
      {destination, type} ->
        conn
        |> Plug.Conn.put_status(type)
        |> Redirect.call(external: destination)
        |> Plug.Conn.halt()

      nil ->
        conn
    end
  end

  defp determine_destination({%Regex{} = pattern, destination, type}, path) do
    case Regex.run(pattern, path, capture: :all_but_first) do
      [captured] ->
        {String.replace(destination, "*", captured), type}

      nil ->
        nil
    end
  end

  defp determine_destination({pattern, destination, type}, path) do
    if pattern == path do
      {destination, type}
    else
      nil
    end
  end
end
