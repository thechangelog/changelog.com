defmodule Changelog.Admin.ChannelView do
  use Changelog.Web, :view

  def episode_count(channel) do
    Changelog.Channel.episode_count channel
  end

  import Scrivener.HTML
end
