defmodule Changelog.Repo.Migrations.RenameEpisodeSubheadlineToSubtitle do
  use Ecto.Migration

  def change do
    rename table(:episodes), :subheadline, to: :subtitle
  end
end
