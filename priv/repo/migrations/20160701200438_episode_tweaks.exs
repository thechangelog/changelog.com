defmodule Changelog.Repo.Migrations.EpisodeTweaks do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :subtitle, :string
      add :notes, :text
    end

    drop table(:episode_links)
  end
end
