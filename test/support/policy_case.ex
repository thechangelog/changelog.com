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
      @all [@guest, @user, @admin, @host]
    end
  end
end
