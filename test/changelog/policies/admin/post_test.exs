defmodule Changelog.Policies.Admin.PostTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.Post

  test "only admins and editors can new/create/index" do
    for policy <- [:new, :create, :index] do
      refute apply(Post, policy, [@guest])
      refute apply(Post, policy, [@user])
      refute apply(Post, policy, [@host])
      assert apply(Post, policy, [@admin])
      assert apply(Post, policy, [@editor])
    end
  end

  test "only admins, post author, post editor can show/edit/update/publish" do
    for policy <- [:show, :edit, :update, :publish] do
      refute apply(Post, policy, [@guest, %{}])
      refute apply(Post, policy, [@user, %{}])
      refute apply(Post, policy, [@editor, %{}])
      refute apply(Post, policy, [@host, %{}])
      refute apply(Post, policy, [@editor, %{author: @user}])
      assert apply(Post, policy, [@admin, %{}])
      assert apply(Post, policy, [@editor, %{author: @editor}])
      assert apply(Post, policy, [@editor, %{author: @user, editor: @editor}])
    end
  end

  test "nobody can delete published post" do
    refute Post.delete(@guest, %{})
    refute Post.delete(@user, %{})
    refute Post.delete(@editor, %{})
    refute Post.delete(@host, %{})
    refute Post.delete(@admin, %{})
  end

  test "post author, post editor, and admin can delete if it's not published" do
    refute Post.delete(@editor, %{author: @editor, published: true})
    refute Post.delete(@editor, %{author: @user, published: false})
    assert Post.delete(@editor, %{author: @editor, published: false})
    assert Post.delete(@editor, %{author: @user, editor: @editor, published: false})
    assert Post.delete(@admin, %{author: @editor, published: false})
  end
end
