defmodule ChangelogWeb.PageView do
  use ChangelogWeb, :public_view

  alias Changelog.{Person, Repo}
  alias ChangelogWeb.{EpisodeView, PersonView, TimeView}

  def members_count, do: Repo.count(Person.joined())
end
