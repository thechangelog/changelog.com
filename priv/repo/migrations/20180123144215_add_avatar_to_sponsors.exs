defmodule Changelog.Repo.Migrations.AddAvatarToSponsors do
  use Ecto.Migration

  def change do
    alter table(:sponsors) do
      add :avatar, :string
    end
  end
end
