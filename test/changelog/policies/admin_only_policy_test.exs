defmodule Changelog.AdminOnlyPolicyTest do
  use ExUnit.Case

  alias Changelog.AdminOnlyPolicy

  @guest nil
  @user %{id: 1, admin: false}
  @admin %{id: 2, admin: true}
  @host %{id: 3, host: true}

  test "only admins can new/create" do
    refute AdminOnlyPolicy.create(@guest)
    refute AdminOnlyPolicy.new(@user)
    refute AdminOnlyPolicy.new(@host)
    assert AdminOnlyPolicy.create(@admin)
  end

  test "only admins can index" do
    refute AdminOnlyPolicy.index(@guest)
    refute AdminOnlyPolicy.index(@user)
    refute AdminOnlyPolicy.index(@host)
    assert AdminOnlyPolicy.index(@admin)
  end

  test "only admins can show" do
    refute AdminOnlyPolicy.show(@guest, %{})
    refute AdminOnlyPolicy.show(@user, %{})
    refute AdminOnlyPolicy.show(@host, %{})
    assert AdminOnlyPolicy.show(@admin, %{})
  end

  test "only admins can edit/update" do
    refute AdminOnlyPolicy.edit(@guest, %{})
    refute AdminOnlyPolicy.update(@user, %{})
    assert AdminOnlyPolicy.update(@admin, %{})
  end

  test "only admins can delete" do
    refute AdminOnlyPolicy.delete(@guest, %{})
    refute AdminOnlyPolicy.delete(@user, %{})
    assert AdminOnlyPolicy.delete(@admin, %{})
  end
end
