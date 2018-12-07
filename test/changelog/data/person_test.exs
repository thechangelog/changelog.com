defmodule Changelog.PersonTest do
  use Changelog.DataCase

  alias Changelog.Person

  @valid_attrs %{name: "Joe Blow", email: "joe@blow.com", handle: "joeblow"}
  @invalid_attrs %{}

  test "insert_changeset with valid attributes" do
    changeset = Person.insert_changeset(%Person{}, @valid_attrs)
    assert changeset.valid?
  end

  test "insert_changeset with invalid attributes" do
    changeset = Person.insert_changeset(%Person{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "admin_update_changeset with a local file path image URL attribute" do
    person = insert(:person)
    local_file_path = File.cwd! <> "/test/fixtures/avatar600x600.png"
    attrs = Map.put(@valid_attrs, :avatar, local_file_path)

    changeset = Person.admin_update_changeset(person, attrs)

    assert changeset.valid?
    refute Map.has_key?(changeset.changes, :avatar)
  end

  test "encoded_auth and decoded_data" do
    user = %Person{email: "jenny@hits.com", auth_token: "8675309"}
    {:ok, encoded} = Person.encoded_auth(user)

    assert encoded == "6A656E6E7940686974732E636F6D7C38363735333039"

    assert ["jenny@hits.com", "8675309"] = Person.decoded_data(encoded)
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

  describe "sans_fake_data" do
    test "scrubs name and handle if name came from Faker" do
      person = Person.with_fake_data(build(:person))
      sans = Person.sans_fake_data(person)
      assert is_nil(sans.name)
      assert is_nil(sans.handle)
    end
  end
end
