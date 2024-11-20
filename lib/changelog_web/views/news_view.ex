defmodule ChangelogWeb.NewsView do
  import ChangelogWeb.Helpers.SharedHelpers, only: [word_count: 1]

  alias Changelog.{Regexp, StringKit}

  @doc """
  Returns a list of tuples, each one representing a headline (sans the lede).
  The first element is the representative emoji, the second the headline text.
  """
  def headlines(episode) do
    content = episode.email_content || ""
    subject = episode.email_subject || ""
    first = String.first(subject) || "-1"

    content
    |> String.split(Regexp.new_line())
    |> Enum.filter(&String.match?(&1, Regexp.top_story()))
    |> Enum.map(&StringKit.md_delinkify/1)
    |> Enum.map(&String.trim_leading(&1, "## "))
    |> Enum.map(&String.trim_leading(&1, "### "))
    |> Enum.reject(fn s -> String.contains?(s, first) end)
    |> Enum.map(fn s ->
      [emoj | rest] = String.split(s, " ")

      {emoj, Enum.join(rest, " ")}
    end)
  end

  def title(%{email_subject: subject, title: title}) do
    subject || title
  end

  def read_duration(%{email_content: nil}), do: 0

  # assumes 250 words per minute
  def read_duration(%{email_content: content}) do
    minutes_to_read = word_count(content) / 250 * 60
    round(minutes_to_read / 60)
  end

  def listen_duration(%{audio_duration: nil}), do: 0

  def listen_duration(%{audio_duration: duration}) do
    round(duration / 60)
  end
end
