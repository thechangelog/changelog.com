defmodule Changelog.PolicyCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Changelog.Policies

      @guest nil
      @user %{id: 1, admin: false}
      @admin %{id: 2, admin: true}
      @editor %{id: 3, editor: true}
      @host %{id: 4, host: true}
      @member %{
        id: 5,
        admin: false,
        editor: false,
        host: false,
        active_membership: %{}
      }
      @all [@guest, @user, @admin, @host, @member]
    end
  end
end
