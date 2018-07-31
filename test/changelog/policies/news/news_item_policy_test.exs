defmodule Changelog.NewsItemPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.NewsItemPolicy

  test "only admins and editors can new/create" do
    refute NewsItemPolicy.create(@guest)
    refute NewsItemPolicy.new(@user)
    refute NewsItemPolicy.new(@host)
    assert NewsItemPolicy.create(@admin)
    assert NewsItemPolicy.new(@editor)
  end

  test "only admins and editors can get the index" do
    refute NewsItemPolicy.index(@guest)
    refute NewsItemPolicy.index(@user)
    refute NewsItemPolicy.index(@host)
    assert NewsItemPolicy.index(@admin)
    assert NewsItemPolicy.index(@editor)
  end

  test "only admins and item logger can edit/update" do
    refute NewsItemPolicy.edit(@guest, %{})
    refute NewsItemPolicy.update(@user, %{})
    refute NewsItemPolicy.update(@editor, %{})
    refute NewsItemPolicy.edit(@host, %{})
    assert NewsItemPolicy.update(@admin, %{})
    assert NewsItemPolicy.edit(@editor, %{logger: @editor})
  end

  test "only admins can move/decline/unpublish/delete" do
    for policy <- [:move, :decline, :unpublish, :delete] do
      refute apply(NewsItemPolicy, policy, [@guest, %{}])
      refute apply(NewsItemPolicy, policy, [@user, %{}])
      refute apply(NewsItemPolicy, policy, [@editor, %{}])
      refute apply(NewsItemPolicy, policy, [@host, %{}])
      assert apply(NewsItemPolicy, policy, [@admin, %{}])
    end
  end

  test "item logger can delete if it's not published" do
    refute NewsItemPolicy.delete(@editor, %{logger: @editor, status: :published})
    refute NewsItemPolicy.delete(@editor, %{logger: @admin, status: :draft})
    assert NewsItemPolicy.delete(@editor, %{logger: @editor, status: :draft})
    assert NewsItemPolicy.delete(@editor, %{logger: @editor, status: :queued})
  end
end
