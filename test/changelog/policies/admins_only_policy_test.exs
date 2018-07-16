defmodule Changelog.AdminsOnlyPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.AdminsOnlyPolicy

  test "only admins can new/create" do
    refute AdminsOnlyPolicy.create(@guest)
    refute AdminsOnlyPolicy.new(@user)
    refute AdminsOnlyPolicy.new(@editor)
    refute AdminsOnlyPolicy.new(@host)
    assert AdminsOnlyPolicy.create(@admin)
  end

  test "only admins can index" do
    refute AdminsOnlyPolicy.index(@guest)
    refute AdminsOnlyPolicy.index(@user)
    refute AdminsOnlyPolicy.index(@editor)
    refute AdminsOnlyPolicy.index(@host)
    assert AdminsOnlyPolicy.index(@admin)
  end

  test "only admins can show" do
    refute AdminsOnlyPolicy.show(@guest, %{})
    refute AdminsOnlyPolicy.show(@user, %{})
    refute AdminsOnlyPolicy.show(@editor, %{})
    refute AdminsOnlyPolicy.show(@host, %{})
    assert AdminsOnlyPolicy.show(@admin, %{})
  end

  test "only admins can edit/update" do
    refute AdminsOnlyPolicy.edit(@guest, %{})
    refute AdminsOnlyPolicy.update(@user, %{})
    refute AdminsOnlyPolicy.update(@editor, %{})
    refute AdminsOnlyPolicy.update(@host, %{})
    assert AdminsOnlyPolicy.update(@admin, %{})
  end

  test "only admins can delete" do
    refute AdminsOnlyPolicy.delete(@guest, %{})
    refute AdminsOnlyPolicy.delete(@user, %{})
    refute AdminsOnlyPolicy.delete(@editor, %{})
    refute AdminsOnlyPolicy.delete(@host, %{})
    assert AdminsOnlyPolicy.delete(@admin, %{})
  end
end
