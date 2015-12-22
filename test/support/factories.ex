defmodule Changelog.Factories do
  alias Changelog.Repo
  alias Changelog.Person

  def insert_person(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Joe Blow #{Base.encode16(:crypto.rand_bytes(8))}"
    }, attrs)

    %Person{}
    |> Person.changeset(changes)
    |> Repo.insert!
  end
end
