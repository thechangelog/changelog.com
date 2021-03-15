defmodule Changelog.Policies.Admin.AdminsOnlyTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.AdminsOnly

  test "only admins can new/create" do
    refute AdminsOnly.create(@guest)
    refute AdminsOnly.new(@user)
    refute AdminsOnly.new(@editor)
    refute AdminsOnly.new(@host)
    assert AdminsOnly.create(@admin)
  end

  test "only admins can index" do
    refute AdminsOnly.index(@guest)
    refute AdminsOnly.index(@user)
    refute AdminsOnly.index(@editor)
    refute AdminsOnly.index(@host)
    assert AdminsOnly.index(@admin)
  end

  test "only admins can show" do
    refute AdminsOnly.show(@guest, %{})
    refute AdminsOnly.show(@user, %{})
    refute AdminsOnly.show(@editor, %{})
    refute AdminsOnly.show(@host, %{})
    assert AdminsOnly.show(@admin, %{})
  end

  test "only admins can edit/update" do
    refute AdminsOnly.edit(@guest, %{})
    refute AdminsOnly.update(@user, %{})
    refute AdminsOnly.update(@editor, %{})
    refute AdminsOnly.update(@host, %{})
    assert AdminsOnly.update(@admin, %{})
  end

  test "only admins can delete" do
    refute AdminsOnly.delete(@guest, %{})
    refute AdminsOnly.delete(@user, %{})
    refute AdminsOnly.delete(@editor, %{})
    refute AdminsOnly.delete(@host, %{})
    assert AdminsOnly.delete(@admin, %{})
  end
end
