defmodule Changelog.SlackController do
  use Changelog.Web, :controller

  alias Changelog.{Episode}
  alias Changelog.Slack.Countdown

  def countdown(conn, %{"slug" => slug}) do
    time_with_buffer = Timex.subtract(Timex.now, Timex.Duration.from_hours(1.5))

    next =
      Episode.recorded_live
      |> Episode.with_podcast_slug(slug)
      |> Episode.recorded_future_to(time_with_buffer)
      |> Episode.newest_last(:recorded_at)
      |> Episode.limit(1)
      |> Repo.one
      |> Episode.preload_podcast

    json(conn, Countdown.live(next))
  end

  def gotime(conn, _params) do
    redirect(conn, to: slack_path(conn, :countdown, "gotime"))
  end
end
