defmodule Changelog.Repo.Migrations.AddingNewsItemIndexes do
  use Ecto.Migration

  def down do
    execute("DROP FUNCTION item_recommendation(integer, integer)")

    drop(index("news_items", [:published_at]))
    drop(index("news_items", [:click_count]))
  end

  def up do
    create(index("news_items", [:published_at]))
    create(index("news_items", [:click_count]))

    execute("""
    CREATE OR REPLACE FUNCTION item_recommendation(news_item_id INTEGER, num_recommendations INTEGER)
    RETURNS TABLE (
      original_id INTEGER,
      original_tags VARCHAR[],
      id INTEGER,
      headline VARCHAR,
      click_count INTEGER,
      tags VARCHAR[],
      published_at TIMESTAMP,
      num_comments INTEGER,
      ranking INTEGER
    )
    AS $$
      with original_news_item AS (
        SELECT
          news_items.id,
          ARRAY_AGG(DISTINCT topics.slug) AS tags
        FROM news_items
        LEFT OUTER JOIN news_item_topics AS news_item_topics ON
          news_item_topics.item_id = news_items.id
        LEFT OUTER JOIN topics AS topics ON
          topics.id = news_item_topics.topic_id
        WHERE news_items.id = news_item_id
        GROUP BY news_items.id
      )
      SELECT DISTINCT
        (SELECT id FROM original_news_item),
        (SELECT tags FROM original_news_item),
        news_items.id,
        news_items.headline,
        news_items.click_count,
        ARRAY_AGG(DISTINCT topics.slug) AS tags,
        news_items.published_at,
        COUNT(DISTINCT news_item_comments.id)::INTEGER AS num_comments,
        CASE
          WHEN COUNT(DISTINCT news_item_comments.id) <= 10 THEN
            200
          WHEN COUNT(DISTINCT news_item_comments.id) <= 20 THEN
            400
          WHEN COUNT(DISTINCT news_item_comments.id) <= 30 THEN
            600
          WHEN COUNT(DISTINCT news_item_comments.id) <= 40 THEN
            800
          ELSE
            1000
        END +
        CASE
          WHEN ARRAY_AGG(DISTINCT topics.slug) @> (SELECT tags FROM original_news_item) THEN
            2250
          WHEN ARRAY_AGG(DISTINCT topics.slug) <@ (SELECT tags FROM original_news_item) THEN
            1250
        ELSE
            0
        END +
        CASE
          WHEN news_items.click_count > 1500 THEN
            1500
          ELSE
            news_items.click_count
        END +
        CASE
          WHEN ((DATE_PART('year', age(news_items.published_at)) * 12) + (DATE_PART('month', age(news_items.published_at)))) <= 12 THEN
            500
          WHEN ((DATE_PART('year', age(news_items.published_at)) * 12) + (DATE_PART('month', age(news_items.published_at)))) <= 24 THEN
            250
          WHEN ((DATE_PART('year', age(news_items.published_at)) * 12) + (DATE_PART('month', age(news_items.published_at)))) <= 36 THEN
            100
          ELSE
            0
        END
        AS ranking
      FROM
        news_items AS news_items
      LEFT OUTER JOIN news_item_topics AS news_item_topics ON
        news_item_topics.item_id = news_items.id
      LEFT OUTER JOIN topics AS topics ON
        topics.id = news_item_topics.topic_id
      LEFT OUTER JOIN news_item_comments AS news_item_comments ON
        news_item_comments.item_id = news_items.id
      WHERE news_items.id != (SELECT id FROM original_news_item)
      GROUP BY
        news_items.id
      ORDER BY
        ranking DESC NULLS LAST
      LIMIT num_recommendations;
    $$ LANGUAGE SQL;
    """)
  end
end
