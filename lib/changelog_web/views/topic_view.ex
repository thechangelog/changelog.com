defmodule ChangelogWeb.TopicView do
  use ChangelogWeb, :public_view

  alias Changelog.{NewsItem, Topic}
  alias ChangelogWeb.NewsItemView
  alias Changelog.Files.Icon

  def icon_url(topic), do: icon_url(topic, :small)
  def icon_url(topic, version) do
    Icon.url({topic.icon, topic}, version)
    |> String.replace_leading("/priv", "")
  end

  def news_count(topic), do: Topic.news_count(topic)
end
