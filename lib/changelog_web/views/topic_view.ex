defmodule ChangelogWeb.TopicView do
  use ChangelogWeb, :public_view

  alias Changelog.{NewsItem, Topic}
  alias ChangelogWeb.NewsItemView

  def news_count(topic), do: Topic.news_count(topic)
end
