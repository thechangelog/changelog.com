defmodule Changelog.Policies.PersonTest do
  use Changelog.PolicyCase

  import Mock

  alias Changelog.Policies.Person

  test "you can only edit/update yourself" do
    refute Person.update(@guest, @user)
    refute Person.edit(@editor, @user)
    refute Person.update(@admin, @user)
    assert Person.edit(@user, @user)
  end

  describe "profiles" do
    test "you can't enable your own profile sans published episode" do
      with_mocks([
        {Changelog.Person, [], [episode_count: fn _ -> 0 end]},
        {Changelog.Person, [], [news_item_count: fn _ -> 0 end]}
      ]) do
        refute Person.profile(@admin, @user)
        refute Person.profile(@user, @user)
      end
    end

    test "you can enable your own profile with published episode" do
      with_mocks([
        {Changelog.Person, [], [episode_count: fn _ -> 1 end]},
        {Changelog.Person, [], [news_item_count: fn _ -> 0 end]}
      ]) do
        refute Person.profile(@admin, @user)
        assert Person.profile(@user, @user)
      end
    end
  end
end
