defmodule Changelog.Social do
  use ChangelogWeb, :verified_routes

  alias Changelog.Social.Client
  alias Changelog.{Episode, StringKit}
  alias ChangelogWeb.{EpisodeView, PersonView}
  alias ChangelogWeb.Helpers.SharedHelpers

  def post(episode = %Episode{}) do
    episode = Episode.preload_all(episode)
    podcast = episode.podcast

    ann = "#{ann_emoj()} #{ann_text(podcast)}"
    desc = description(episode)
    link = "#{link_emoj()} #{link_url(episode)} #{tags(podcast)}"

    # max status length is 500. 490 for wiggle room
    room_for_desc = 490 - String.length(ann) - String.length(link)

    content = """
    #{ann}

    #{SharedHelpers.truncate(desc, room_for_desc)}

    #{link}
    """

    token = token_for_podcast(podcast)

    case Client.create_status(token, content) do
      {:ok, %{body: body}} -> Episode.socialize_url(episode, body["url"])
      {:error, response} -> {:error, response}
    end
  end

  def description(episode) do
    episode = episode |> Episode.preload_hosts() |> Episode.preload_guests()

    episode.summary
    |> SharedHelpers.md_to_text()
    |> replace_host_references(episode.hosts)
    |> replace_guest_references(episode.guests)
  end

  defp replace_host_references(text, hosts) do
    hosts
    |> Enum.filter(&(StringKit.present?(&1.mastodon_handle)))
    |> Enum.reduce(text, fn host, acc ->
      first_name = PersonView.first_name(host)
      acc
      |> String.replace(host.name, "@" <> host.mastodon_handle)
      |> String.replace(first_name, "@" <> host.mastodon_handle)
    end)
  end

  defp replace_guest_references(text, guests) do
    guests
    |> Enum.filter(&(StringKit.present?(&1.mastodon_handle)))
    |> Enum.reduce(text, fn guest, acc ->
      String.replace(acc, guest.name, "@" <> guest.mastodon_handle)
    end)
  end

  defp ann_emoj, do: ~w(🙌 🎉 🔥 💥 🚢 🚀 ⚡️ ✨ 🤘) |> Enum.random()

  defp ann_text(podcast) do
    case podcast.slug do
      "friends" -> "It's Changelog & Friends!"
      "podcast" -> "New Changelog interview!"
      "shipit" -> "New episode of Ship It!"
      _else -> "New episode of #{podcast.name}!"
    end
  end

  defp link_emoj, do: ~w(✨ 💫 🔗 👉 🎧) |> Enum.random()

  defp link_url(episode), do: episode |> EpisodeView.share_url()

  defp tags(podcast) do
    case podcast.slug do
      "news" -> "#news #podcast"
      "gotime" -> "#golang #podcast"
      _else -> "#podcast"
    end
  end

  defp token_for_podcast(%{mastodon_token: nil}) do
    Client.default_token()
  end

  defp token_for_podcast(%{mastodon_token: token}), do: token
end
