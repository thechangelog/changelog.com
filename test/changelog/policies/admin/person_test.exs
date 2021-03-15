defmodule Changelog.Policies.Admin.PersonTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.Person

  test "only admins can new/create" do
    refute Person.create(@guest)
    refute Person.new(@user)
    refute Person.new(@editor)
    assert Person.create(@admin)
    refute Person.create(@host)
  end

  test "only admins can index" do
    refute Person.index(@guest)
    refute Person.index(@user)
    refute Person.index(@editor)
    refute Person.index(@host)
    assert Person.index(@admin)
  end

  test "nobody can show" do
    refute Person.show(@guest, %{})
    refute Person.show(@user, %{})
    refute Person.show(@editor, %{})
    refute Person.show(@host, %{})
    refute Person.show(@admin, %{})
  end

  describe "only admins can edit/update" do
    refute Person.edit(@guest, %{})
    refute Person.update(@user, %{})
    assert Person.update(@admin, %{})
    refute Person.edit(@host, %{})
  end

  test "only admins can delete" do
    refute Person.delete(@guest, %{})
    refute Person.delete(@user, %{})
    refute Person.delete(@editor, %{})
    refute Person.delete(@host, %{})
    assert Person.delete(@admin, %{})
  end
end
