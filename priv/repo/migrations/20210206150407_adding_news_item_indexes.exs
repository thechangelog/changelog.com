defmodule Changelog.Repo.Migrations.AddingNewsItemIndexes do
  use Ecto.Migration

  def down do
    execute("DROP FUNCTION query_related_news_item(integer, integer)")
    execute("DROP FUNCTION query_related_podcast(integer, integer)")
    execute("DROP FUNCTION query_related_post(integer, integer)")

    drop(index("news_items", [:published_at]))
    drop(index("news_items", [:click_count]))
  end

  def up do
    create(index("news_items", [:published_at]))
    create(index("news_items", [:click_count]))

    execute(related_podcast_function())
    execute(related_news_function())
    execute(related_post_function())
  end

  defp related_post_function do
    """
    CREATE OR REPLACE FUNCTION query_related_post(news_item_id INTEGER, num_recommendations INTEGER)
    RETURNS TABLE (
      original_id BIGINT,
      original_tags VARCHAR[],
      id BIGINT,
      headline VARCHAR,
      url VARCHAR,
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
        (SELECT id FROM original_news_item)::BIGINT,
        (SELECT tags FROM original_news_item),
        news_items.id::BIGINT,
        news_items.headline,
        news_items.url,
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
          WHEN ARRAY_AGG(DISTINCT topics.slug) = (SELECT tags FROM original_news_item) THEN
            2250
          WHEN ARRAY_AGG(DISTINCT topics.slug) <@ (SELECT tags FROM original_news_item) THEN
            1250
          WHEN ARRAY_AGG(DISTINCT topics.slug) && (SELECT tags FROM original_news_item) THEN
            750
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
      WHERE
        news_items.id != (SELECT id FROM original_news_item) AND
        news_items.status = 3 AND
        news_items.published_at <= timezone('utc', now()) AND
        news_items.object_id LIKE 'posts:%'
      GROUP BY
        news_items.id
      ORDER BY
        ranking DESC NULLS LAST
      LIMIT num_recommendations;
    $$ LANGUAGE SQL;
    """
  end

  defp related_podcast_function do
    """
    CREATE OR REPLACE FUNCTION query_related_podcast(episode_id INTEGER, num_recommendations INTEGER)
    RETURNS TABLE (
      original_id BIGINT,
      original_tags VARCHAR[],
      id BIGINT,
      headline VARCHAR,
      url VARCHAR,
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
        INNER JOIN episodes AS episodes ON
          CONCAT(episodes.podcast_id, ':', episodes.id) = news_items.object_id
        LEFT OUTER JOIN news_item_topics AS news_item_topics ON
          news_item_topics.item_id = news_items.id
        LEFT OUTER JOIN topics AS topics ON
          topics.id = news_item_topics.topic_id
        WHERE episodes.id = episode_id
        GROUP BY news_items.id
      )
      SELECT DISTINCT
        (SELECT id FROM original_news_item)::BIGINT,
        (SELECT tags FROM original_news_item),
        news_items.id::BIGINT,
        news_items.headline,
        CASE
          WHEN podcasts.vanity_domain IS NULL OR episodes.slug IS NULL THEN
            news_items.url
          ELSE
            CONCAT(podcasts.vanity_domain, '/', episodes.slug)
        END AS url,
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
          WHEN ARRAY_AGG(DISTINCT topics.slug) = (SELECT tags FROM original_news_item) THEN
            2250
          WHEN ARRAY_AGG(DISTINCT topics.slug) <@ (SELECT tags FROM original_news_item) THEN
            1250
          WHEN ARRAY_AGG(DISTINCT topics.slug) && (SELECT tags FROM original_news_item) THEN
            750
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
      INNER JOIN episodes AS episodes ON
        CONCAT(episodes.podcast_id, ':', episodes.id) = news_items.object_id
      INNER JOIN podcasts AS podcasts ON
        episodes.podcast_id = podcasts.id
      LEFT OUTER JOIN news_item_topics AS news_item_topics ON
        news_item_topics.item_id = news_items.id
      LEFT OUTER JOIN topics AS topics ON
        topics.id = news_item_topics.topic_id
      LEFT OUTER JOIN news_item_comments AS news_item_comments ON
        news_item_comments.item_id = news_items.id
      WHERE
        news_items.id != (SELECT id FROM original_news_item) AND
        news_items.status = 3 AND
        news_items.published_at <= timezone('utc', now())
      GROUP BY
        news_items.id, podcasts.vanity_domain, episodes.slug
      ORDER BY
        ranking DESC NULLS LAST
      LIMIT num_recommendations;
    $$ LANGUAGE SQL;
    """
  end

  defp related_news_function do
    """
    CREATE OR REPLACE FUNCTION query_related_news_item(news_item_id INTEGER, num_recommendations INTEGER)
    RETURNS TABLE (
      original_id BIGINT,
      original_tags VARCHAR[],
      id BIGINT,
      headline VARCHAR,
      url VARCHAR,
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
        (SELECT id FROM original_news_item)::BIGINT,
        (SELECT tags FROM original_news_item),
        news_items.id::BIGINT,
        news_items.headline,
        news_items.url,
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
          WHEN ARRAY_AGG(DISTINCT topics.slug) = (SELECT tags FROM original_news_item) THEN
            2250
          WHEN ARRAY_AGG(DISTINCT topics.slug) <@ (SELECT tags FROM original_news_item) THEN
            1250
          WHEN ARRAY_AGG(DISTINCT topics.slug) && (SELECT tags FROM original_news_item) THEN
            750
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
      WHERE
        news_items.id != (SELECT id FROM original_news_item) AND
        news_items.status = 3 AND
        news_items.published_at <= timezone('utc', now()) AND
        news_items.pinned AND
        NOT news_items.feed_only
      GROUP BY
        news_items.id
      ORDER BY
        ranking DESC NULLS LAST
      LIMIT num_recommendations;
    $$ LANGUAGE SQL;
    """
  end
end
