defmodule Changelog.Helpers.ViewHelpers do
  use Phoenix.HTML

  defmacro __using__(_) do
    quote do
      import Changelog.Helpers.ViewHelpers
    end
  end

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
  end

  def error_message(form, field) do
    if message = form.errors[field] do
      content_tag :div, class: "ui pointing red basic label" do
        message
      end
    end
  end

  def external_link(text, opts) do
    link text, (opts ++ [rel: "external"])
  end

  def github_link(model) do
    if model.github_handle do
      external_link model.github_handle, to: "https://github.com/#{model.github_handle}"
    end
  end

  def twitter_link(model) do
    if model.twitter_handle do
      external_link model.twitter_handle, to: "https://twitter.com/#{model.twitter_handle}"
    end
  end

  def website_link(model) do
    if model.website do
      external_link model.website, to: model.website
    end
  end
end
