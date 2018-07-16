defmodule Changelog.AdminPolicyTest do
  use ExUnit.Case

  alias Changelog.AdminPolicy

  @guest nil
  @user %{id: 1, admin: false}
  @admin %{id: 2, admin: true}
  @editor %{id: 3, editor: true}
  @host %{id: 4, host: true}

  test "only admins, editors, and hosts can index" do
    refute AdminPolicy.index(@guest)
    refute AdminPolicy.index(@user)
    assert AdminPolicy.index(@admin)
    assert AdminPolicy.index(@editor)
    assert AdminPolicy.index(@host)
  end
end
