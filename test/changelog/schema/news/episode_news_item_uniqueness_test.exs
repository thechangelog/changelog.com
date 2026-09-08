defmodule Changelog.EpisodeNewsItemUniquenessTest do
  use Changelog.SchemaCase

  alias Changelog.{Episode, NewsItem}

  @index "news_items_episode_object_id_unique"

  test "the episode object-id index is unique, ready and valid" do
    result =
      Ecto.Adapters.SQL.query!(Repo, """
      SELECT indisunique, indisready, indisvalid, pg_get_indexdef(indexrelid)
      FROM pg_index WHERE indexrelid = 'public.#{@index}'::regclass
      """)

    assert [[true, true, true, definition]] = result.rows

    assert definition ==
             "CREATE UNIQUE INDEX #{@index} ON public.news_items USING btree (object_id) " <>
               "WHERE ((object_id)::text ~ '^[1-9][0-9]*:[1-9][0-9]*$'::text)"
  end

  for {status, feed_only, type} <- [
        {:draft, true, :audio},
        {:queued, false, :audio},
        {:published, true, :audio},
        {:published, false, :video}
      ] do
    test "rejects duplicate #{status}/#{feed_only}/#{type} episode object IDs" do
      episode = insert(:published_episode)
      object_id = Episode.object_id(episode)
      insert(:news_item, object_id: object_id)

      assert_raise Ecto.ConstraintError, ~r/news_items_episode_object_id_unique/, fn ->
        insert(:news_item,
          object_id: object_id,
          status: unquote(status),
          feed_only: unquote(feed_only),
          type: unquote(type)
        )
      end
    end
  end

  test "rejects an update into an existing episode object ID" do
    episode = insert(:published_episode)
    object_id = Episode.object_id(episode)
    insert(:news_item, object_id: object_id)
    other = insert(:news_item, object_id: "news:uniqueness-test")

    assert_raise Ecto.ConstraintError, ~r/news_items_episode_object_id_unique/, fn ->
      other |> Ecto.Changeset.change(object_id: object_id) |> Repo.update!()
    end
  end

  test "distinct podcast and episode IDs remain independent" do
    for object_id <- ["1:900000001", "2:900000001", "2:900000002"] do
      insert(:news_item, object_id: object_id)
    end
  end

  test "the reserved namespace is enforced even without a matching episode" do
    insert(:news_item, object_id: "999999999:999999999")

    assert_raise Ecto.ConstraintError, ~r/news_items_episode_object_id_unique/, fn ->
      insert(:news_item, object_id: "999999999:999999999")
    end
  end

  test "null and non-episode historical namespaces are not made unique" do
    for object_id <- [nil, "news:183", "posts:42", "01:2", "0:2", "1:0", "1:2:3"] do
      first = insert(:news_item, object_id: object_id)
      second = insert(:news_item, object_id: object_id)
      assert first.id != second.id
      assert Repo.get!(NewsItem, second.id).object_id == object_id
    end
  end
end
