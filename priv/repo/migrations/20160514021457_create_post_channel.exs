defmodule Changelog.Repo.Migrations.CreatePostChannel do
  use Ecto.Migration

  def change do
    create table(:post_channels) do
      add :position, :integer
      add :channel_id, references(:channels, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end

    create index(:post_channels, [:channel_id])
    create index(:post_channels, [:post_id])
    create unique_index(:post_channels, [:post_id, :channel_id])
  end
end
