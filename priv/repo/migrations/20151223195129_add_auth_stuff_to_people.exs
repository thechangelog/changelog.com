defmodule Changelog.Repo.Migrations.AddAuthStuffToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :auth_token, :string
      add :auth_token_expires_at, :naive_datetime
      add :signed_in_at, :naive_datetime
    end
  end
end
