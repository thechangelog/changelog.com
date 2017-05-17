defmodule Changelog.SlackController do
  use Changelog.Web, :controller

  alias Changelog.{Episode}
  alias Changelog.Slack.Countdown

  require Logger

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

  def event(conn, %{"type" => "url_verification", "challenge" => challenge}) do
    json(conn, %{challenge: challenge})
  end

  def event(conn, %{"type" => "event_callback", "event" => %{"type" => "team_join", "user" => _user}}) do
    json(conn, %{})
  end

  def event(conn, params) do
    Logger.info("Slack: Unhandled event #{inspect(params)}")
    conn
    |> put_resp_header("x-slack-no-retry", "1")
    |> send_resp(:method_not_allowed, "")
  end
end
