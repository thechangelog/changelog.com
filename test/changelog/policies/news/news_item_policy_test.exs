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

  test "only admins can decline" do
    refute NewsItemPolicy.decline(@guest, %{})
    refute NewsItemPolicy.decline(@user, %{})
    refute NewsItemPolicy.decline(@editor, %{})
    refute NewsItemPolicy.decline(@host, %{})
    assert NewsItemPolicy.decline(@admin, %{})
  end

  test "only admins can unpublish" do
    refute NewsItemPolicy.unpublish(@guest, %{})
    refute NewsItemPolicy.unpublish(@user, %{})
    refute NewsItemPolicy.unpublish(@editor, %{})
    refute NewsItemPolicy.unpublish(@host, %{})
    assert NewsItemPolicy.unpublish(@admin, %{})
  end

  test "only admins can delete" do
    refute NewsItemPolicy.delete(@guest, %{})
    refute NewsItemPolicy.delete(@user, %{})
    refute NewsItemPolicy.delete(@editor, %{})
    refute NewsItemPolicy.delete(@host, %{})
    assert NewsItemPolicy.delete(@admin, %{})
  end
end
