defmodule Changelog.PostPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.PostPolicy

  test "only admins and editors can new/create/index" do
    for policy <- [:new, :create, :index] do
      refute apply(PostPolicy, policy, [@guest])
      refute apply(PostPolicy, policy, [@user])
      refute apply(PostPolicy, policy, [@host])
      assert apply(PostPolicy, policy, [@admin])
      assert apply(PostPolicy, policy, [@editor])
    end
  end

  test "only admins and post author can show/edit/update" do
    for policy <- [:show, :edit, :update] do
      refute apply(PostPolicy, policy, [@guest, %{}])
      refute apply(PostPolicy, policy, [@user, %{}])
      refute apply(PostPolicy, policy, [@editor, %{}])
      refute apply(PostPolicy, policy, [@host, %{}])
      assert apply(PostPolicy, policy, [@admin, %{}])
      assert apply(PostPolicy, policy, [@editor, %{author: @editor}])
    end
  end

  test "only admins can delete" do
    refute PostPolicy.delete(@guest, %{})
    refute PostPolicy.delete(@user, %{})
    refute PostPolicy.delete(@editor, %{})
    refute PostPolicy.delete(@host, %{})
    assert PostPolicy.delete(@admin, %{})
  end

  test "post author can delete if it's not published" do
    refute PostPolicy.delete(@editor, %{author: @editor, published: true})
    refute PostPolicy.delete(@editor, %{author: @user, published: false})
    assert PostPolicy.delete(@editor, %{author: @editor, published: false})
  end
end
