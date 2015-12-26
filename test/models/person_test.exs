defmodule Changelog.PersonTest do
  use Changelog.ModelCase

  alias Changelog.Person

  @valid_attrs %{name: "Joe Blow", email: "joe@blow.com", handle: "joeblow"}
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

  test "encoded_auth and decoded_auth" do
    user = %Person{email: "jenny@hits.com", auth_token: "8675309"}
    {:ok, encoded} = Person.encoded_auth(user)

    assert encoded == "6A656E6E7940686974732E636F6D7C38363735333039"

    assert ["jenny@hits.com", "8675309"] = Person.decoded_auth(encoded)
  end
end
