defmodule Changelog.PageView do
  use Changelog.Web, :view

  def with_smart_quotes(string) do
    string
    |> String.replace_leading("\"", "“")
    |> String.replace_trailing("\"", "”")
  end
end
