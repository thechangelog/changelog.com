defmodule Changelog.BenefitView do
  use Changelog.Web, :public_view

  def link_url(benefit) do
    if benefit.link_url do
      benefit.link_url
    else
      benefit.sponsor.website
    end
  end
end
