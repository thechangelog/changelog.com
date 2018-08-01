defmodule Changelog.Policies.SearchTest do
  use Changelog.PolicyCase

  alias Changelog.Policies

  test "only admins can search all and one with no params" do
    for policy <- [:all, :one] do
      refute apply(Policies.Search, policy, [@guest])
      refute apply(Policies.Search, policy, [@user])
      refute apply(Policies.Search, policy, [@editor])
      refute apply(Policies.Search, policy, [@host])
      assert apply(Policies.Search, policy, [@admin])
    end
  end

  test "only admins/hosts/editors can search 'one' with topic/person/news_source type" do
    for type <- ["topic", "news_source", "person"] do
      refute Policies.Search.one(@user, type)
      refute Policies.Search.one(@guest, type)
      assert Policies.Search.one(@host, type)
      assert Policies.Search.one(@editor, type)
      assert Policies.Search.one(@admin, type)
    end
  end
end
