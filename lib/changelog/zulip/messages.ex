defmodule Changelog.Zulip.Messages do
  alias Changelog.ListKit
  alias ChangelogWeb.{EpisodeView, TimeView}

  def cross_post(episode, channel, topic) do
    "#{EpisodeView.podcast_name_and_number(episode)}! Discuss 👉 #**#{channel}>#{topic}**"
  end

  def new_episode(episode) do
    [
      summary(episode),
      chapters(episode)
    ]
    |> ListKit.compact_join("\n\n")
  end

  def summary(episode) do
    "#{episode.summary} 🔗 #{episode_url(episode)}"
  end

  def chapters(%{audio_chapters: nil}), do: nil
  def chapters(%{audio_chapters: []}), do: nil

  def chapters(episode = %{audio_chapters: chapters}, padding \\ 2) do
    numbers =
      chapters
      |> Enum.with_index(1)
      |> Enum.map(fn {_c, i} ->
        Integer.to_string(i) |> String.pad_leading(padding, "0")
      end)

    numbers_length = max_length(numbers) + padding

    starts = chapters |> Enum.map(&TimeView.duration(&1.starts_at))
    starts_length = max_length(starts) + padding

    titles = chapters |> Enum.map(& &1.title)
    titles_length = max_length(titles) + padding

    runs = chapters |> Enum.map(&TimeView.duration(&1.ends_at - &1.starts_at))
    runs_length = max_length(runs) + padding

    headers =
      [
        "Ch" |> pad(numbers_length),
        "Start" |> pad(starts_length),
        "Title" |> pad(titles_length),
        "Runs" |> pad(runs_length)
      ]
      |> Enum.join("|")

    dividers =
      [
        "-" |> String.duplicate(numbers_length - padding) |> pad(numbers_length),
        "-" |> String.duplicate(starts_length - padding) |> pad(starts_length),
        "-" |> String.duplicate(titles_length - padding) |> pad(titles_length),
        "-" |> String.duplicate(runs_length - padding) |> pad(runs_length)
      ]
      |> Enum.join("|")

    rows =
      chapters
      |> Enum.with_index(0)
      |> Enum.map(fn {chapter, index} ->
        [
          pad(Enum.at(numbers, index), numbers_length),
          linkify(
            pad(Enum.at(starts, index), starts_length),
            Enum.at(starts, index),
            episode_url(episode, chapter.starts_at)
          ),
          linkify(
            pad(Enum.at(titles, index), titles_length),
            chapter.title,
            chapter.link_url
          ),
          pad(Enum.at(runs, index), runs_length)
        ]
        |> Enum.join("|")
      end)

    [headers, dividers, rows]
    |> List.flatten()
    |> Enum.map(&"|#{&1}|")
    |> Enum.join("\n")
  end

  defp episode_url(episode, starts_at \\ nil) do
    if starts_at do
      EpisodeView.share_url(episode) <> "#t=#{round(starts_at)}"
    else
      EpisodeView.share_url(episode)
    end
  end

  defp linkify(string, _title, nil), do: string

  defp linkify(string, title, link) do
    String.replace(string, title, "[#{title}](#{link})")
  end

  defp max_length(list) do
    list |> Enum.max_by(&String.length/1) |> String.length()
  end

  defp pad(string, length) do
    String.pad_trailing(" #{string}", length, " ")
  end
end
