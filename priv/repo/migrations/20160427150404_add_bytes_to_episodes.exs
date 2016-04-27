defmodule Changelog.Repo.Migrations.AddBytesToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :bytes, :integer, default: 0
    end
  end
end
