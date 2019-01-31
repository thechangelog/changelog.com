defmodule ChangelogWeb.Plug.LoadPodcasts do
  import Plug.Conn

  alias Changelog.Cache

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :podcasts, Cache.podcasts())
  end
end
