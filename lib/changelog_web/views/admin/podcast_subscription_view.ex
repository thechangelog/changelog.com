defmodule ChangelogWeb.Admin.PodcastSubscriptionView do
  use ChangelogWeb, :admin_view

  alias Changelog.Subscription
  alias ChangelogWeb.PersonView

  def chart_data(podcast) do
    this_month = Timex.today() |> Timex.beginning_of_month()

    stats =
      Enum.map(11..0, fn i ->
        start_date = Timex.shift(this_month, months: -i)
        start_time = start_date |> Timex.to_datetime() |> Timex.beginning_of_day()
        end_time = start_date |> Timex.end_of_month() |> Timex.to_datetime() |> Timex.end_of_day()

        subs = Subscription.subscribed_count(podcast, start_time, end_time)
        unsubs = Subscription.unsubscribed_count(podcast, start_time, end_time)

        %{date: start_date, subs: subs, unsubs: unsubs}
      end)

    data = %{
      title: "Subs by Month",
      categories: Enum.map(stats, &chart_category/1),
      series: [
        %{name: "Subs", data: Enum.map(stats, & &1.subs)},
        %{name: "Unsubs", data: Enum.map(stats, & &1.unsubs)}
      ]
    }

    Jason.encode!(data)
  end

  defp chart_category(stat) do
    {:ok, date} = Timex.format(stat.date, "{Mshort} {YY}")
    date
  end

  def recent_subscription_counts(podcast, days \\ 30) do
    start_time = Timex.now()
    end_time = Timex.shift(start_time, days: -days)

    up = podcast |> Subscription.subscribed_count(start_time, end_time)
    down = podcast |> Subscription.unsubscribed_count(start_time, end_time)
    {up, down}
  end

  def total_subscribed_count(podcast) do
    podcast |> Subscription.subscribed_count() |> SharedHelpers.comma_separated()
  end

  def total_unsubscribed_count(podcast) do
    podcast |> Subscription.unsubscribed_count() |> SharedHelpers.comma_separated()
  end
end
