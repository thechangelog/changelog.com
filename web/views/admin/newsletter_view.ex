defmodule Changelog.Admin.NewsletterView do
  def subscribers(newsletter, period) do
    field = case period do
      :daily   -> "NewActiveSubscribersToday"
      :weekly  -> "NewActiveSubscribersThisWeek"
      :monthly -> "NewActiveSubscribersThisMonth"
      _else    -> "TotalActiveSubscribers"
    end

    Map.get(newsletter.stats, field, 0)
  end

  def web_url(newsletter) do
    "http://email.changelog.com/subscribers/listDetail.aspx?listID=#{newsletter.web_id}"
  end
end
