defmodule Changelog.Repo.Migrations.ChangePostNewsItemTypes do
  use Ecto.Migration

  def up do
    execute "UPDATE news_items SET type=5 WHERE object_id LIKE 'posts:%'"
  end

  def down do
    execute "UPDATE news_items SET type=0 WHERE object_id LIKE 'posts:%'"
  end
end
