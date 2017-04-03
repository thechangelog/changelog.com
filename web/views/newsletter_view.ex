defmodule Changelog.NewsletterView do
  def subscribers(newsletter, period, fallback \\ 0) do
    field = case period do
      :daily   -> "NewActiveSubscribersToday"
      :weekly  -> "NewActiveSubscribersThisWeek"
      :monthly -> "NewActiveSubscribersThisMonth"
      _else    -> "TotalActiveSubscribers"
    end

    Map.get(newsletter.stats, field, fallback)
  end
end
