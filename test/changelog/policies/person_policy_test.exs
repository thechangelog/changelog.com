defmodule Changelog.PersonPolicyTest do
  use ExUnit.Case

  alias Changelog.PersonPolicy

  @guest nil
  @user %{id: 1, admin: false}
  @admin %{id: 2, admin: true}
  @host %{id: 3, admin: false, host: true}

  test "admins and hosts can new/create" do
    refute PersonPolicy.create(@guest)
    refute PersonPolicy.new(@user)
    assert PersonPolicy.create(@admin)
    assert PersonPolicy.create(@host)
  end

  test "only admins can index" do
    refute PersonPolicy.index(@guest)
    refute PersonPolicy.index(@user)
    refute PersonPolicy.index(@host)
    assert PersonPolicy.index(@admin)
  end

  test "nobody can show" do
    refute PersonPolicy.show(@guest, %{})
    refute PersonPolicy.show(@user, %{})
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
    refute PersonPolicy.delete(@host, %{})
    assert PersonPolicy.delete(@admin, %{})
  end
end
