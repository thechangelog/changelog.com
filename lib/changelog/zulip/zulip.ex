defmodule Changelog.Zulip do

  alias Changelog.Zulip.Client
  alias Changelog.{Episode, Person, Podcast}
  alias ChangelogWeb.EpisodeView

  def invite(person = %Person{}) do
    Client.post_invite(person.email)
  end

  def post(episode = %Episode{}) do
    episode = Episode.preload_all(episode)

    channel = Podcast.slug_with_interviews_special_case(episode.podcast)
    topic = "#{episode.slug}: #{episode.title}"
    content = """
    #{episode.summary}

    🔗 #{EpisodeView.share_url(episode)}
    """

    case Client.post_message(channel, topic, content) do
      %{"ok" => true} -> cross_post(episode, channel, topic)
      _else -> nil
    end
  end

  def user_id(person = %Person{}) do
    case Client.get_user(person.email) do
      %{"ok" => true, "user" => %{"user_id" => id}} -> {:ok, id}
      %{"ok" => false} -> {:error, nil}
    end
  end

  defp cross_post(episode, channel, topic) do
    content = "#{EpisodeView.podcast_name_and_number(episode)}! Discuss 👉 #**#{channel}>#{topic}**"

    Client.post_message("general", "new episodes", content)
  end
end
