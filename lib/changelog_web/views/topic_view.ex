defmodule ChangelogWeb.TopicView do
  use ChangelogWeb, :public_view

  alias Changelog.Topic
  alias ChangelogWeb.{Endpoint, NewsItemView}
  alias Changelog.Files.Icon

  def admin_edit_link(conn, user, topic) do
    if user && user.admin do
      link("[Edit]", to: admin_topic_path(conn, :edit, topic.slug, next: current_path(conn)), data: [turbolinks: false])
    end
  end

  def icon_path(topic, version) do
    {topic.icon, topic}
    |> Icon.url(version)
    |> String.replace_leading("/priv", "")
  end

  def icon_url(topic), do: icon_url(topic, :small)
  def icon_url(topic, version) do
    if topic.icon do
      static_url(Endpoint, icon_path(topic, version))
    else
      "/images/defaults/avatar-topic.png"
    end
  end

  def news_count(topic), do: Topic.news_count(topic)
end
