defmodule Changelog.Admin.ChannelView do
  use Changelog.Web, :view

  # import Scrivener.HTML

  def episode_count(channel) do
    Changelog.Channel.episode_count(channel)
  end

  def post_count(channel) do
    Changelog.Channel.post_count(channel)
  end
end
