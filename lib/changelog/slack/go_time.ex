defmodule Changelog.Slack.GoTime do
  alias Timex.Duration

  def countdown(nil) do
    respond(":sob: There aren't any upcoming recordings :sob:")
  end

  def countdown(next_episode) do
    diff = Timex.diff(next_episode.recorded_at, Timex.now, :duration)
    formatted = Timex.format_duration(diff, :humanized)

    respond(case Duration.to_hours(diff) do
      h when h < 0  -> ":tada: It's noOOoOow GO TIME!! Listen: https://changelog.com/live :tada:"
      h when h < 2  -> ":eyes: There's just *#{formatted}* until Go Time :eyes:"
      h when h < 24 -> ":sweat_smile: There's only *#{formatted}* until Go Time :sweat_smile:"
      _else -> ":pensive: There's still *#{formatted}* until Go Time :pensive:"
    end)
  end

  defp respond(text) do
    %Changelog.Slack.Response{text: text}
  end
end
