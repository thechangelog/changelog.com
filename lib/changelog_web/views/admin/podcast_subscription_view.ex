defmodule ChangelogWeb.Admin.PodcastSubscriptionView do
  use ChangelogWeb, :admin_view

  alias Changelog.Subscription
  alias ChangelogWeb.PersonView

  def recent_subscription_counts(podcast) do
    start_time = Timex.now()
    end_time = Timex.shift(start_time, days: -30)

    up = podcast |> Subscription.subscribed_count(start_time, end_time)
    down = podcast |> Subscription.unsubscribed_count(start_time, end_time)
    {up, down}
  end

  def total_subscribed_count(podcast) do
    podcast |> Subscription.subscribed_count() |> comma_separated()
  end

  def total_unsubscribed_count(podcast) do
    podcast |> Subscription.unsubscribed_count() |> comma_separated()
  end
end
