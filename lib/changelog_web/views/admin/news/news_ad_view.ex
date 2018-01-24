defmodule ChangelogWeb.Admin.NewsAdView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.NewsItemView

  def image_url(ad, version), do: NewsItemView.image_url(ad, version)
end
