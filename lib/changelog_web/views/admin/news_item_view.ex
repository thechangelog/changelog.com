defmodule ChangelogWeb.Admin.NewsItemView do
  use ChangelogWeb, :admin_view

  alias Changelog.NewsItem

  def type_options do
    NewsItem.Type.__enum_map__()
    |> Enum.map(fn({k, _v}) -> {String.capitalize(Atom.to_string(k)), k} end)
  end
end
