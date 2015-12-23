defmodule Changelog.Helpers.ViewHelpers do
  use Phoenix.HTML

  defmacro __using__(_) do
    quote do
      import Changelog.Helpers.ViewHelpers
    end
  end

  def external_link(text, opts) do
    link text, (opts ++ [rel: "external"])
  end
end
