defmodule ChangelogWeb.Admin.ChannelView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Channel}

  def episode_count(channel) do
    Channel.episode_count(channel)
  end

  def post_count(channel) do
    Channel.post_count(channel)
  end
end
