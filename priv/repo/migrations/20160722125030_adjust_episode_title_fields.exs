defmodule Changelog.Repo.Migrations.AdjustEpisodeTitleFields do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :subheadline, :string
      add :highlight, :string
      add :subhighlight, :string
      add :featured, :boolean, default: false
    end

    rename table(:episodes), :subtitle, to: :headline
  end
end
