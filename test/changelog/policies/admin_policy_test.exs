defmodule Changelog.AdminPolicyTest do
  use Changelog.PolicyCase

  alias Changelog.AdminPolicy

  test "only admins, editors, and hosts can index" do
    refute AdminPolicy.index(@guest)
    refute AdminPolicy.index(@user)
    assert AdminPolicy.index(@admin)
    assert AdminPolicy.index(@editor)
    assert AdminPolicy.index(@host)
  end
end
