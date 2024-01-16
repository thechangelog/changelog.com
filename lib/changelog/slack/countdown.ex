defmodule Changelog.Slack.Countdown do
  alias Timex.Duration
  alias ChangelogWeb.LiveView

  def live(nil), do: respond("No live recordings scheduled yet...")

  def live(next_episode) do
    diff = Timex.diff(next_episode.recorded_at, Timex.now(), :duration)
    formatted = Timex.format_duration(diff, :humanized)
    podcast = next_episode.podcast.name
    title = next_episode.title

    respond(
      case Duration.to_hours(diff) do
        h when h <= 0 ->
          "#{live_message(podcast)}! Watch ~> #{LiveView.live_url(next_episode)} :tada:"

        h when h < 2 ->
          "There's just *#{formatted}* until #{podcast} (#{title}) :eyes:"

        h when h < 24 ->
          "There's only *#{formatted}* until #{podcast} (#{title}) :sweat_smile:"

        _else ->
          "There's still *#{formatted}* until #{podcast} (#{title}) :hourglass_flowing_sand:"
      end,
      next_episode.recorded_at
    )
  end

  defp respond(text), do: %Changelog.Slack.Response{text: text}
  defp respond(text, data), do: %Changelog.Slack.Response{text: text, data: data}

  defp live_message("Go Time"), do: "It's Go Time"
  defp live_message("JS Party"), do: "JS Party Time, y'all"
  defp live_message(name), do: "#{name} is recording live"
end
