defmodule ChangelogWeb.NewsIssueView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.NewsItemView

  def spacer_url do
    "https://changelog-assets.s3.amazonaws.com/weekly/spacer.gif"
  end
end
