defmodule Changelog.PersonPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.PersonPolicy

  test "admins and hosts can new/create" do
    refute PersonPolicy.create(@guest)
    refute PersonPolicy.new(@user)
    refute PersonPolicy.new(@editor)
    assert PersonPolicy.create(@admin)
    assert PersonPolicy.create(@host)
  end

  test "only admins can index" do
    refute PersonPolicy.index(@guest)
    refute PersonPolicy.index(@user)
    refute PersonPolicy.index(@editor)
    refute PersonPolicy.index(@host)
    assert PersonPolicy.index(@admin)
  end

  test "nobody can show" do
    refute PersonPolicy.show(@guest, %{})
    refute PersonPolicy.show(@user, %{})
    refute PersonPolicy.show(@editor, %{})
    refute PersonPolicy.show(@host, %{})
    refute PersonPolicy.show(@admin, %{})
  end

  describe "only hosts and admins can edit/update" do
    refute PersonPolicy.edit(@guest, %{})
    refute PersonPolicy.update(@user, %{})
    assert PersonPolicy.update(@admin, %{})
    assert PersonPolicy.edit(@host, %{})
  end

  test "only admins can delete" do
    refute PersonPolicy.delete(@guest, %{})
    refute PersonPolicy.delete(@user, %{})
    refute PersonPolicy.delete(@editor, %{})
    refute PersonPolicy.delete(@host, %{})
    assert PersonPolicy.delete(@admin, %{})
  end
end
