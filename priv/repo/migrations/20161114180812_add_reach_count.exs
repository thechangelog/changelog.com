defmodule Changelog.Repo.Migrations.AddReachCount do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add(:reach_count, :integer, default: 0)
    end

    alter table(:episodes) do
      add(:reach_count, :integer, default: 0)
    end
  end
end
