defmodule ChangelogWeb.Admin.NewsletterView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.NewsletterView

  def web_url(newsletter) do
    "http://email.changelog.com/subscribers/listDetail.aspx?listID=#{newsletter.web_id}"
  end

  def subscribers(newsletter, period), do: NewsletterView.subscribers(newsletter, period)

  def unsubscribers(newsletter, period, fallback \\ 0) do
    field = case period do
      :daily   -> "UnsubscribesToday"
      :weekly  -> "UnsubscribesThisWeek"
      :monthly -> "UnsubscribesThisMonth"
      _else    -> "TotalUnsubscribes"
    end

    Map.get(newsletter.stats, field, fallback)
  end
end
