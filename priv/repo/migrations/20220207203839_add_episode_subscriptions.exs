defmodule Changelog.Repo.Migrations.AddEpisodeSubscriptions do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add(:episode_id, references(:episodes, on_delete: :delete_all))
    end

    create index(:subscriptions, [:episode_id])
  end
end
