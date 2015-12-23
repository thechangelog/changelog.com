defmodule Changelog.Repo.Migrations.AddAuthStuffToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :auth_token, :string
      add :auth_token_expires_at, :datetime
      add :signed_in_at, :datetime
    end
  end
end
