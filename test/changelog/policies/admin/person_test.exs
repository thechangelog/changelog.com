defmodule Changelog.Policies.Admin.PersonTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.Person

  test "admins, editors, and hosts can new/create" do
    refute Person.create(@guest)
    refute Person.new(@user)
    assert Person.new(@editor)
    assert Person.create(@admin)
    assert Person.create(@host)
  end

  test "admins, editors, and hosts can index" do
    refute Person.index(@guest)
    refute Person.index(@user)
    assert Person.index(@editor)
    assert Person.index(@host)
    assert Person.index(@admin)
  end

  test "admins, editors, and hosts can show" do
    refute Person.show(@guest, %{})
    refute Person.show(@user, %{})
    assert Person.show(@editor, %{})
    assert Person.show(@host, %{})
    assert Person.show(@admin, %{})
  end

  describe "admins, editors, and hosts can edit/update" do
    refute Person.edit(@guest, %{})
    refute Person.update(@user, %{})
    assert Person.update(@admin, %{})
    assert Person.edit(@host, %{})
    assert Person.edit(@editor, %{})
  end

  test "only admins can delete" do
    refute Person.delete(@guest, %{})
    refute Person.delete(@user, %{})
    refute Person.delete(@editor, %{})
    refute Person.delete(@host, %{})
    assert Person.delete(@admin, %{})
  end

  test "only admins can set roles" do
    refute Person.roles(@guest, %{})
    refute Person.roles(@user, %{})
    refute Person.roles(@editor, %{})
    refute Person.roles(@host, %{})
    assert Person.roles(@admin, %{})
  end
end
