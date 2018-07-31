defmodule Changelog.SearchPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.SearchPolicy

  test "only admins can search all and one with no params" do
    for policy <- [:all, :one] do
      refute apply(SearchPolicy, policy, [@guest])
      refute apply(SearchPolicy, policy, [@user])
      refute apply(SearchPolicy, policy, [@editor])
      refute apply(SearchPolicy, policy, [@host])
      assert apply(SearchPolicy, policy, [@admin])
    end
  end

  test "only admins/hosts/editors can search 'one' with topic/person/news_source type" do
    for type <- ["topic", "news_source", "person"] do
      refute SearchPolicy.one(@user, type)
      refute SearchPolicy.one(@guest, type)
      assert SearchPolicy.one(@host, type)
      assert SearchPolicy.one(@editor, type)
      assert SearchPolicy.one(@admin, type)
    end
  end
end
