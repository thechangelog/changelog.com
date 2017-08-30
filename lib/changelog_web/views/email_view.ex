defmodule ChangelogWeb.EmailView do
  use ChangelogWeb, :public_view

  alias ChangelogWeb.{AuthView, Endpoint, PersonView}

  def auth_link_expires_in(person) do
    diff = Timex.diff(person.auth_token_expires_at, Timex.now, :duration)
    Timex.format_duration(diff, :humanized)
  end
end
