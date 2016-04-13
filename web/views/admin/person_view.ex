defmodule Changelog.Admin.PersonView do
  use Changelog.Web, :view

  import Scrivener.HTML

  def avatar_url(person) do
    gravatar_url(person.email, 100)
  end

  def avatar_url(person, size) do
    gravatar_url(person.email, size)
  end

  defp gravatar_url(email, size) do
    hash = email
      |> String.strip
      |> String.downcase
      |> :erlang.md5
      |> Base.encode16(case: :lower)

    "https://secure.gravatar.com/avatar/#{hash}.jpg?s=#{size}&d=mm"
  end
end
