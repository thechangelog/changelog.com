defmodule Changelog.Repo.Migrations.AddNewsItemDeclineMessage do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      add :decline_message, :string, default: ""
    end
  end
end
