defmodule Changelog.Repo.Migrations.RenameDeclineMessageToMessage do
  use Ecto.Migration

  def change do
    rename table(:news_items), :decline_message, to: :message
    rename table(:episode_requests), :decline_message, to: :message
  end
end
