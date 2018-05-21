defmodule Hello.Repo.Migrations.RemoveAuthTokenExpiresAtFromPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      remove(:auth_token_expires_at)
    end
  end
end
