defmodule Changelog.SlackController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, Podcast}
  alias Changelog.Slack.GoTime

  def gotime(conn, _params) do
    podcast = Repo.get_by!(Podcast, slug: "gotime")
    time_with_buffer = Timex.subtract(Timex.now, Timex.Duration.from_hours(1.5))

    next =
      assoc(podcast, :episodes)
      |> Episode.unpublished
      |> Episode.recorded_future_to(time_with_buffer)
      |> Episode.newest_last(:recorded_at)
      |> Episode.limit(1)
      |> Repo.one

    json(conn, GoTime.countdown(next))
  end
end
