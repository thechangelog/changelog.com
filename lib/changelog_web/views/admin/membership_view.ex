defmodule ChangelogWeb.Admin.MembershipView do
  use ChangelogWeb, :admin_view

  alias ChangelogWeb.PersonView

  def status_label(membership) do
    if membership.status == :active do
      content_tag(:span, "Active", class: "ui tiny green basic label")
    else
      content_tag(:span, "Canceled", class: "ui tiny yellow basic label")
    end
  end

  def stripe_url(membership) do
    "https://dashboard.stripe.com/subscriptions/#{membership.subscription_id}"
  end
end
