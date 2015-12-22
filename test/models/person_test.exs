defmodule Changelog.PersonTest do
  use Changelog.ModelCase

  alias Changelog.Person

  @valid_attrs %{name: "Joe Blow", email: "joe@blow.com"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Person.changeset(%Person{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Person.changeset(%Person{}, @invalid_attrs)
    refute changeset.valid?
  end
end
