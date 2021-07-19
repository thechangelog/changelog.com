defmodule ChangelogWeb.Plug.Robots do
  @moduledoc """
  Responds to robots.txt requests depending on host requested. We only want
  changelog.com indexed, not its sub-domains or other domains.
  """
  import ChangelogWeb.Plug.Conn

  def init(opts), do: opts

  def call(conn = %{request_path: "/robots.txt"}, _opts) do
    host = get_host(conn)
    Plug.Conn.send_resp(conn, 200, response_for_host(host))
  end

  def call(conn, _opts), do: conn

  # defp response_for_host("changelog.com") do
  #   """
  #   sitemap: https://changelog.com/sitemap.xml
  #   user-agent: *
  #   disallow: /ad/impress
  #   disallow: /news/impress
  #   disallow: /auth/github
  #   disallow: /auth/twitter
  #   """
  # end

  defp response_for_host(_host) do
    """
    user-agent: *
    disallow: /
    """
  end
end
