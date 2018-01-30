defmodule ChangelogWeb.Admin.NewsSponsorshipView do
  use ChangelogWeb, :admin_view

  alias Changelog.{NewsSponsorship, Sponsor}
  alias ChangelogWeb.Endpoint
  alias ChangelogWeb.Admin.{NewsAdView}

  def schedule_cell_class(focus_week, week, sponsorship) when is_nil(sponsorship) do
    focus_week_with_buffer = Timex.shift(focus_week, weeks: 1)
    cond do
      Timex.equal?(week, focus_week) -> "negative"
      Timex.equal?(week, focus_week_with_buffer) -> "negative"
      Timex.after?(week, focus_week_with_buffer) -> "warning"
      true -> ""
    end
  end
  def schedule_cell_class(_focus_week, _week, _sponsorship), do: "positive"

  def schedule_cell_content(focus_week, week, sponsorship) when is_nil(sponsorship) do
    cond do
      Timex.before?(week, focus_week) -> "None"
      true -> link("Available", to: admin_news_sponsorship_path(Endpoint, :new, week: Date.to_string(week)))
    end
  end
  def schedule_cell_content(_focus_week, _week, sponsorship) do
    render("_schedule_cell_content.html", sponsorship: sponsorship)
  end

  def schedule_row_class(focus_week, week) do
    cond do
      Timex.before?(week, focus_week) -> "disabled"
      Timex.equal?(week, focus_week) -> "active"
      true -> ""
    end
  end

  def sponsorships_for_week(monday) do
    monday
    |> NewsSponsorship.week_of
    |> Changelog.Repo.all
    |> NewsSponsorship.preload_sponsor
  end

  def sponsor_and_campaign_name(sponsorship) do
    [sponsorship.sponsor.name, sponsorship.name]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" – ")
  end
end
