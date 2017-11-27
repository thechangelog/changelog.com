defmodule Changelog.Repo.Migrations.CreateNewsSponsorships do
  use Ecto.Migration

  def change do
    create table(:news_sponsorships) do
      add :name, :string
      add :sponsor_id, references(:sponsors)
      add :impression_count, :integer, default: 0
      add :click_count, :integer, default: 0
      add :weeks, {:array, :date}

      timestamps()
    end

  end
end
