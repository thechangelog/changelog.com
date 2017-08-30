defmodule ChangelogWeb.BenefitView do
  use ChangelogWeb, :public_view

  def link_url(benefit) do
    if benefit.link_url do
      benefit.link_url
    else
      benefit.sponsor.website
    end
  end
end
