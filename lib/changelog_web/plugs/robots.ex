defmodule ChangelogWeb.Plug.Robots do
  @moduledoc """
  Responds to robots.txt requests depending on host requested. We only want
  changelog.com indexed, not its sub-domains or other domains.
  """
  import ChangelogWeb.Plug.Conn
  import Plug.Conn

  def init(opts), do: opts

  def call(conn = %{request_path: "/robots.txt"}, _opts) do
    response =
      conn
      |> get_host()
      |> response_for_host()

    conn
    |> send_resp(200, response)
    |> halt()
  end

  def call(conn, _opts), do: conn

  defp response_for_host("changelog.com") do
    """
    sitemap: https://changelog.com/sitemap.xml
    user-agent: *
    disallow: /ad/impress
    disallow: /news/impress
    disallow: /auth/github
    disallow: /auth/twitter
    disallow: /search?*
    """
  end

  defp response_for_host("cdn.changelog.com") do
    """
    user-agent: *
    allow: /images/
    allow: /uploads/
    disallow: /
    """
  end

  defp response_for_host(_host) do
    """
    user-agent: *
    disallow: /
    """
  end
end
