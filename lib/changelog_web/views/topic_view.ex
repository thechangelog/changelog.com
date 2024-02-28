defmodule ChangelogWeb.TopicView do
  use ChangelogWeb, :public_view

  alias Changelog.Topic
  alias ChangelogWeb.{EpisodeView}
  alias Changelog.Files.Icon

  def admin_edit_link(conn, %{admin: true}, topic) do
    link("[edit]",
      to:
        Routes.admin_topic_path(conn, :edit, topic.slug, next: SharedHelpers.current_path(conn))
    )
  end

  def admin_edit_link(_, _, _), do: nil

  def icon_path(topic, version), do: Icon.url({topic.icon, topic}, version)

  def icon_url(topic), do: icon_url(topic, :small)

  def icon_url(topic, version) do
    if topic.icon do
      icon_path(topic, version)
    else
      url(~p"/images/defaults/avatar-topic.png")
    end
  end

  def news_count(topic), do: Topic.news_count(topic)
end
