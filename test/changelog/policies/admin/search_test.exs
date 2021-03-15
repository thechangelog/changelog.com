defmodule Changelog.Policies.Admin.SearchTest do
  use Changelog.PolicyCase

  alias Changelog.Policies.Admin.Search

  test "only admins can search all and one with no params" do
    for policy <- [:all, :one] do
      refute apply(Search, policy, [@guest])
      refute apply(Search, policy, [@user])
      refute apply(Search, policy, [@editor])
      refute apply(Search, policy, [@host])
      assert apply(Search, policy, [@admin])
    end
  end

  test "only admins/hosts/editors can search 'one' with topic/person/news_source type" do
    for type <- ["topic", "news_source", "person"] do
      refute Search.one(@user, type)
      refute Search.one(@guest, type)
      assert Search.one(@host, type)
      assert Search.one(@editor, type)
      assert Search.one(@admin, type)
    end
  end
end
