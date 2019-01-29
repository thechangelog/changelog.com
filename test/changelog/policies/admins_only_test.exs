defmodule Changelog.Policies.AdminsOnlyTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins can new/create" do
    refute Policies.AdminsOnly.create(@guest)
    refute Policies.AdminsOnly.new(@user)
    refute Policies.AdminsOnly.new(@editor)
    refute Policies.AdminsOnly.new(@host)
    assert Policies.AdminsOnly.create(@admin)
  end

  test "only admins can index" do
    refute Policies.AdminsOnly.index(@guest)
    refute Policies.AdminsOnly.index(@user)
    refute Policies.AdminsOnly.index(@editor)
    refute Policies.AdminsOnly.index(@host)
    assert Policies.AdminsOnly.index(@admin)
  end

  test "only admins can show" do
    refute Policies.AdminsOnly.show(@guest, %{})
    refute Policies.AdminsOnly.show(@user, %{})
    refute Policies.AdminsOnly.show(@editor, %{})
    refute Policies.AdminsOnly.show(@host, %{})
    assert Policies.AdminsOnly.show(@admin, %{})
  end

  test "only admins can edit/update" do
    refute Policies.AdminsOnly.edit(@guest, %{})
    refute Policies.AdminsOnly.update(@user, %{})
    refute Policies.AdminsOnly.update(@editor, %{})
    refute Policies.AdminsOnly.update(@host, %{})
    assert Policies.AdminsOnly.update(@admin, %{})
  end

  test "only admins can delete" do
    refute Policies.AdminsOnly.delete(@guest, %{})
    refute Policies.AdminsOnly.delete(@user, %{})
    refute Policies.AdminsOnly.delete(@editor, %{})
    refute Policies.AdminsOnly.delete(@host, %{})
    assert Policies.AdminsOnly.delete(@admin, %{})
  end
end
