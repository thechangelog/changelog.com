defmodule Changelog.Factories do
  alias Changelog.Repo
  alias Changelog.Person

  def random_string(char_count \\ 8) do
    Base.encode16(:crypto.rand_bytes(char_count))
  end

  def insert_person(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Joe Blow #{random_string}",
      email: "joe-#{random_string}@email.com",
      handle: "joeblow-#{String.downcase(random_string)}"
    }, attrs)

    %Person{}
    |> Person.changeset(changes)
    |> Repo.insert!
  end
end
