defmodule ChangelogWeb.Admin.TopicView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Topic}

  def episode_count(topic) do
    Topic.episode_count(topic)
  end

  def post_count(topic) do
    Topic.post_count(topic)
  end
end
