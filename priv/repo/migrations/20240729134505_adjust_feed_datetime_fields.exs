defmodule Changelog.Repo.Migrations.AdjustFeedDatetimeFields do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      remove :starts_at
      add :starts_on, :date
      add :refreshed_at, :utc_datetime
    end
  end
end
