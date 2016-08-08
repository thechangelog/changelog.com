defmodule Changelog.Repo.Migrations.SponsorDescriptionsToText do
  use Ecto.Migration

  def change do
    alter table(:sponsors) do
      modify :description, :text
    end

    alter table(:episode_sponsors) do
      modify :description, :text
    end
  end
end
