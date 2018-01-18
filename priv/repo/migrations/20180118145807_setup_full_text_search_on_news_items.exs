defmodule Changelog.Repo.Migrations.SetupFullTextSearchOnNewsItems do
  use Ecto.Migration

  def up do
    alter table(:news_items) do
      add :search_vector, :tsvector
    end

    execute "CREATE extension if not exists pg_trgm;"

    execute "CREATE INDEX news_items_search_index ON news_items USING GIN(search_vector);"

    # Create trigger functions that weigh the fields and populate the index.
    # https://www.postgresql.org/docs/9.6/static/functions-textsearch.html
    execute "CREATE OR REPLACE FUNCTION news_item_search_trigger() RETURNS trigger AS $$
      begin
          new.search_vector :=
            setweight(to_tsvector('pg_catalog.english', coalesce(new.headline,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(new.story,'')), 'B');
        return new;
      end
    $$ LANGUAGE plpgsql"

    # Create triggers to update the search vectors on insertion or change
    # https://www.postgresql.org/docs/9.6/static/sql-createtrigger.html
    execute "CREATE TRIGGER news_item_search_update
      BEFORE INSERT OR UPDATE OF story, headline
      ON news_items
      FOR EACH ROW
      EXECUTE PROCEDURE news_item_search_trigger();"

    # Populate the search vectors initially
    execute "UPDATE news_items SET headline=headline;"
  end

  def down do
    execute "DROP INDEX news_items_search_index;"
    execute "DROP TRIGGER news_item_search_update ON news_items;"
    execute "DROP FUNCTION news_item_search_trigger();"

    alter table(:news_items) do
      remove :search_vector
    end
  end
end
