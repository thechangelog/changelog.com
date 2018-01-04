defmodule ChangelogWeb.Admin.TopicView do
  use ChangelogWeb, :admin_view

  alias Changelog.Topic
  alias ChangelogWeb.TopicView

  def icon_url(topic), do: TopicView.icon_url(topic)

  def episode_count(topic), do: Topic.episode_count(topic)
  def news_count(topic), do: Topic.news_count(topic)
  def post_count(topic), do: Topic.post_count(topic)
end
