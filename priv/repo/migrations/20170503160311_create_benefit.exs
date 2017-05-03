defmodule Changelog.Repo.Migrations.CreateBenefit do
  use Ecto.Migration

  def change do
    create table(:benefits) do
      add :offer, :string
      add :code, :string
      add :notes, :text
      add :link_url, :string
      add :sponsor_id, references(:sponsors)

      timestamps()
    end

    create index(:benefits, [:sponsor_id])
  end
end
