defmodule Changelog.Repo.Migrations.MoarPersonFields do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:location, :string)
      add(:slack_id, :string)
      add(:joined_at, :naive_datetime)
    end
  end
end
