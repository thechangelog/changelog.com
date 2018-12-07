defmodule Changelog.Policies.PostTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins and editors can new/create/index" do
    for policy <- [:new, :create, :index] do
      refute apply(Policies.Post, policy, [@guest])
      refute apply(Policies.Post, policy, [@user])
      refute apply(Policies.Post, policy, [@host])
      assert apply(Policies.Post, policy, [@admin])
      assert apply(Policies.Post, policy, [@editor])
    end
  end

  test "only admins and post author can show/edit/update" do
    for policy <- [:show, :edit, :update] do
      refute apply(Policies.Post, policy, [@guest, %{}])
      refute apply(Policies.Post, policy, [@user, %{}])
      refute apply(Policies.Post, policy, [@editor, %{}])
      refute apply(Policies.Post, policy, [@host, %{}])
      assert apply(Policies.Post, policy, [@admin, %{}])
      assert apply(Policies.Post, policy, [@editor, %{author: @editor}])
    end
  end

  test "only admins can delete" do
    refute Policies.Post.delete(@guest, %{})
    refute Policies.Post.delete(@user, %{})
    refute Policies.Post.delete(@editor, %{})
    refute Policies.Post.delete(@host, %{})
    assert Policies.Post.delete(@admin, %{})
  end

  test "post author can delete if it's not published" do
    refute Policies.Post.delete(@editor, %{author: @editor, published: true})
    refute Policies.Post.delete(@editor, %{author: @user, published: false})
    assert Policies.Post.delete(@editor, %{author: @editor, published: false})
  end
end
