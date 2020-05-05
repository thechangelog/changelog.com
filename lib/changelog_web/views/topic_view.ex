defmodule ChangelogWeb.TopicView do
  use ChangelogWeb, :public_view

  alias Changelog.Topic
  alias ChangelogWeb.{Endpoint, NewsItemView}
  alias Changelog.Files.Icon

  def admin_edit_link(conn, %{admin: true}, topic) do
    link("[edit]",
      to:
        Routes.admin_topic_path(conn, :edit, topic.slug, next: SharedHelpers.current_path(conn)),
      data: [turbolinks: false]
    )
  end

  def admin_edit_link(_, _, _), do: nil

  def icon_path(topic, version) do
    {topic.icon, topic}
    |> Icon.url(version)
    |> String.replace_leading("/priv", "")
  end

  def icon_url(topic), do: icon_url(topic, :small)

  def icon_url(topic, version) do
    if topic.icon do
      Routes.static_url(Endpoint, icon_path(topic, version))
    else
      "/images/defaults/avatar-topic.png"
    end
  end

  def news_count(topic), do: Topic.news_count(topic)
end
