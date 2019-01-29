defmodule Changelog.Policies.PersonTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins can new/create" do
    refute Policies.Person.create(@guest)
    refute Policies.Person.new(@user)
    refute Policies.Person.new(@editor)
    assert Policies.Person.create(@admin)
    refute Policies.Person.create(@host)
  end

  test "only admins can index" do
    refute Policies.Person.index(@guest)
    refute Policies.Person.index(@user)
    refute Policies.Person.index(@editor)
    refute Policies.Person.index(@host)
    assert Policies.Person.index(@admin)
  end

  test "nobody can show" do
    refute Policies.Person.show(@guest, %{})
    refute Policies.Person.show(@user, %{})
    refute Policies.Person.show(@editor, %{})
    refute Policies.Person.show(@host, %{})
    refute Policies.Person.show(@admin, %{})
  end

  describe "only admins can edit/update" do
    refute Policies.Person.edit(@guest, %{})
    refute Policies.Person.update(@user, %{})
    assert Policies.Person.update(@admin, %{})
    refute Policies.Person.edit(@host, %{})
  end

  test "only admins can delete" do
    refute Policies.Person.delete(@guest, %{})
    refute Policies.Person.delete(@user, %{})
    refute Policies.Person.delete(@editor, %{})
    refute Policies.Person.delete(@host, %{})
    assert Policies.Person.delete(@admin, %{})
  end
end
