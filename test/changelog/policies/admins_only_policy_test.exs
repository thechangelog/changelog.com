defmodule Changelog.AdminsOnlyPolicyTest do
  use ExUnit.Case

  alias Changelog.AdminsOnlyPolicy

  @guest nil
  @user %{id: 1, admin: false}
  @admin %{id: 2, admin: true}
  @host %{id: 3, host: true}

  test "only admins can new/create" do
    refute AdminsOnlyPolicy.create(@guest)
    refute AdminsOnlyPolicy.new(@user)
    refute AdminsOnlyPolicy.new(@host)
    assert AdminsOnlyPolicy.create(@admin)
  end

  test "only admins can index" do
    refute AdminsOnlyPolicy.index(@guest)
    refute AdminsOnlyPolicy.index(@user)
    refute AdminsOnlyPolicy.index(@host)
    assert AdminsOnlyPolicy.index(@admin)
  end

  test "only admins can show" do
    refute AdminsOnlyPolicy.show(@guest, %{})
    refute AdminsOnlyPolicy.show(@user, %{})
    refute AdminsOnlyPolicy.show(@host, %{})
    assert AdminsOnlyPolicy.show(@admin, %{})
  end

  test "only admins can edit/update" do
    refute AdminsOnlyPolicy.edit(@guest, %{})
    refute AdminsOnlyPolicy.update(@user, %{})
    assert AdminsOnlyPolicy.update(@admin, %{})
  end

  test "only admins can delete" do
    refute AdminsOnlyPolicy.delete(@guest, %{})
    refute AdminsOnlyPolicy.delete(@user, %{})
    assert AdminsOnlyPolicy.delete(@admin, %{})
  end
end
