defmodule Changelog.Repo.Migrations.AddExtendedDescriptionToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add(:extended_description, :text)
    end
  end
end
