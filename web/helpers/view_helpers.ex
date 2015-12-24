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
end
