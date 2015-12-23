defmodule Changelog.Admin.PersonView do
  use Changelog.Web, :view
  use Changelog.Helpers.ViewHelpers

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
  end

  def github_link(p) do
    if p.github_handle do
      external_link p.github_handle, to: "https://github.com/#{p.github_handle}"
    end
  end

  def twitter_link(p) do
    if p.twitter_handle do
      external_link p.twitter_handle, to: "https://twitter.com/#{p.twitter_handle}"
    end
  end

  def website_link(p) do
    if p.website do
      external_link p.website, to: p.website
    end
  end
end
