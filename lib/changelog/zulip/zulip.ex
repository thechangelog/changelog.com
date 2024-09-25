defmodule Changelog.Zulip do

  alias Changelog.Zulip.Client
  alias Changelog.Episode
  alias ChangelogWeb.EpisodeView

  def post(episode = %Episode{}) do
    episode = Episode.preload_all(episode)

    channel = episode.podcast.slug
    topic = "#{episode.slug}: #{episode.title}"
    content = """
    #{episode.summary}

    🔗 #{EpisodeView.share_url(episode)}
    """

    case Client.post_message(channel, topic, content) do
      %{"result" => "success"} -> cross_post(episode, topic)
      _else -> nil
    end
  end

  defp cross_post(episode, topic) do
    channel = "general"
    content = "#{EpisodeView.podcast_name_and_number(episode)}! Discuss 👉 #**#{channel}>#{topic}**"

    Client.post_message(channel, "new episodes", content)
  end
end
