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

  test "encoded_auth and decoded_auth" do
    user = %Person{email: "jenny@hits.com", auth_token: "8675309"}
    {:ok, encoded} = Person.encoded_auth(user)

    assert encoded == "6A656E6E7940686974732E636F6D7C38363735333039"

    assert ["jenny@hits.com", "8675309"] = Person.decoded_auth(encoded)
  end

  describe "get_by_ueberauth" do
    setup do
      person = insert(:person, twitter_handle: "JoeBlow", github_handle: "kokomo")
      [person: person]
    end

    test "it gets person with matching ci twitter handle", context do
      auth = %{provider: :twitter, info: %{nickname: "joeBLOW"}}
      assert Person.get_by_ueberauth(auth) == context[:person]
    end

    test "it gets person with matching ci github handle", context do
      auth = %{provider: :github, info: %{nickname: "KOKOMO"}}
      assert Person.get_by_ueberauth(auth) == context[:person]
    end

    test "it returns nil when no matching ci handles" do
      auth = %{provider: :twitter, info: %{nickname: "joejoe"}}
      assert Person.get_by_ueberauth(auth) == nil
    end

    test "it returns nil when no provider match" do
      assert Person.get_by_ueberauth(%{}) == nil
    end
  end
end
