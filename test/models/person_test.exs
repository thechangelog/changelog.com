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

  test "is_admin when email is in the list" do
    user = %Person{email: "adam@changelog.com"}
    assert Person.is_admin(user)
  end

  test "is_admin is false when email is not in the list" do
    user = %Person{}
    refute Person.is_admin(user)
  end
end
