defmodule Changelog.Repo.Migrations.SetupFullTextSearch do
  use Ecto.Migration

  def up do
    # For episodes and posts we create a search vector index that contains the searchable columns.
    # The indexes gets updated by triggers that fire on insertion or change.
    # The indexes contain the particular fields in weighed form.
    #
    # For further details see these two posts and the postgres docs:
    # http://www.brightball.com/articles/postgresql-functions-with-elixir-ecto
    # https://hashrocket.com/blog/posts/exploring-postgres-gin-index
    # https://www.postgresql.org/docs/9.6/static/textsearch-intro.html

    alter table(:episodes) do
      add :search_vector, :tsvector
    end

    alter table(:posts) do
      add :search_vector, :tsvector
    end

    execute "CREATE extension if not exists pg_trgm;"

    execute "CREATE INDEX episodes_search_index ON episodes USING GIN(search_vector);"
    execute "CREATE INDEX posts_search_index ON posts USING GIN(search_vector);"

    # Create trigger functions that weigh the fields and populate the index.
    # https://www.postgresql.org/docs/9.6/static/functions-textsearch.html
    execute "CREATE OR REPLACE FUNCTION episode_search_trigger() RETURNS trigger AS $$
      begin
          new.search_vector :=
            setweight(to_tsvector('pg_catalog.english', coalesce(new.title,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(new.summary,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(new.notes,'')), 'B');
        return new;
      end
    $$ LANGUAGE plpgsql"

    execute "CREATE OR REPLACE FUNCTION post_search_trigger() RETURNS trigger AS $$
      begin
          new.search_vector :=
            setweight(to_tsvector('pg_catalog.english', coalesce(new.title,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(new.tldr,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(new.body,'')), 'B');
        return new;
      end
    $$ LANGUAGE plpgsql"

    # Create triggers to update the search vectors on insertion or change
    # https://www.postgresql.org/docs/9.6/static/sql-createtrigger.html
    execute "CREATE TRIGGER episode_search_update
      BEFORE INSERT OR UPDATE OF title, summary, notes
      ON episodes
      FOR EACH ROW
      EXECUTE PROCEDURE episode_search_trigger();"

    execute "CREATE TRIGGER post_search_update
      BEFORE INSERT OR UPDATE OF title, tldr, body
      ON posts
      FOR EACH ROW
      EXECUTE PROCEDURE post_search_trigger();"

    # Populate the search vectors initially
    execute "UPDATE episodes SET title=title;"
    execute "UPDATE posts SET title=title;"
  end

  def down do
    execute "DROP INDEX episodes_search_index;"
    execute "DROP INDEX posts_search_index;"
    execute "DROP TRIGGER episode_search_update ON episodes;"
    execute "DROP TRIGGER post_search_update ON posts;"
    execute "DROP FUNCTION episode_search_trigger();"
    execute "DROP FUNCTION post_search_trigger();"

    alter table(:episodes) do
      remove :search_vector
    end

    alter table(:posts) do
      remove :search_vector
    end
  end

end
