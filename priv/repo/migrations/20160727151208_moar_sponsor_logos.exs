defmodule Changelog.Repo.Migrations.MoarSponsorLogos do
  use Ecto.Migration

  def change do
    alter table(:sponsors) do
      add :dark_logo, :string
      add :light_logo, :string
    end

    rename table(:sponsors), :logo_image, to: :color_logo
  end
end
