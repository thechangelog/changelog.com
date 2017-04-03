defmodule Changelog.Slack.Countdown do
  alias Timex.Duration

  def live(nil) do
    respond(":sob: There aren't any upcoming live recordings :sob:")
  end

  def live(next_episode) do
    diff = Timex.diff(next_episode.recorded_at, Timex.now, :duration)
    formatted = Timex.format_duration(diff, :humanized)
    podcast = next_episode.podcast.name

    respond(case Duration.to_hours(diff) do
      h when h < 0  -> ":tada: #{live_message(podcast)}! Listen: https://changelog.com/live :tada:"
      h when h < 2  -> ":eyes: There's just *#{formatted}* until #{podcast} :eyes:"
      h when h < 24 -> ":sweat_smile: There's only *#{formatted}* until #{podcast} :sweat_smile:"
      _else -> ":pensive: There's still *#{formatted}* until #{podcast} :pensive:"
    end)
  end

  defp respond(text) do
    %Changelog.Slack.Response{text: text}
  end

  defp live_message("Go Time"), do: "It's noOOoOow GO TIME"
  defp live_message("JS PArty"), do: "It's a JS Party"
  defp live_message(name), do: "#{name} is recording live"
end
