defmodule Changelog.PostPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.PostPolicy

  test "only admins and editors can new/create" do
    refute PostPolicy.create(@guest)
    refute PostPolicy.new(@user)
    refute PostPolicy.new(@host)
    assert PostPolicy.create(@admin)
    assert PostPolicy.new(@editor)
  end

  test "only admins and editors can get the index" do
    refute PostPolicy.index(@guest)
    refute PostPolicy.index(@user)
    refute PostPolicy.index(@host)
    assert PostPolicy.index(@admin)
    assert PostPolicy.index(@editor)
  end

  test "only admins and post author can show" do
    refute PostPolicy.show(@guest, %{})
    refute PostPolicy.show(@user, %{})
    refute PostPolicy.show(@editor, %{})
    refute PostPolicy.show(@host, %{})
    assert PostPolicy.show(@admin, %{})
    assert PostPolicy.show(@editor, %{author: @editor})
  end

  test "only admins and post author can edit/update" do
    refute PostPolicy.edit(@guest, %{})
    refute PostPolicy.update(@user, %{})
    refute PostPolicy.update(@editor, %{})
    refute PostPolicy.edit(@host, %{})
    assert PostPolicy.update(@admin, %{})
    assert PostPolicy.edit(@editor, %{author: @editor})
  end

  test "only admins can delete" do
    refute PostPolicy.delete(@guest, %{})
    refute PostPolicy.delete(@user, %{})
    refute PostPolicy.delete(@editor, %{})
    refute PostPolicy.delete(@host, %{})
    assert PostPolicy.delete(@admin, %{})
  end
end
