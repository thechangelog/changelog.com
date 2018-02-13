defmodule Changelog.Repo.Migrations.MakeEpisodeHighlightsText do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      modify :highlight, :text
    end
  end
end
