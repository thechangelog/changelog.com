defmodule Changelog.Admin.NewsletterView do

  alias Changelog.NewsletterView

  def web_url(newsletter) do
    "http://email.changelog.com/subscribers/listDetail.aspx?listID=#{newsletter.web_id}"
  end

  def subscribers(newsletter, period), do: NewsletterView.subscribers(newsletter, period)
end
