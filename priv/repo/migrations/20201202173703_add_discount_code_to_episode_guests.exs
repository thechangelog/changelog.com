defmodule Changelog.Repo.Migrations.AddDiscountCodeToEpisodeGuests do
  use Ecto.Migration

  def change do
    alter table(:episode_guests) do
      add :discount_code, :string, default: ""
    end
  end
end
