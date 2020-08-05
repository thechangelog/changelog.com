defmodule Changelog.Repo.Migrations.BreathingRoomForDeclineMessages do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      modify :decline_message, :text
    end

    alter table(:episode_requests) do
      modify :decline_message, :text
    end
  end
end
