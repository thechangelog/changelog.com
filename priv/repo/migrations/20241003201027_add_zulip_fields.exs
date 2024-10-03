defmodule Changelog.Repo.Migrations.AddZulipFields do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :zulip_id, :string
    end

    alter table(:podcasts) do
      add :zulip_url, :string
    end
  end
end
