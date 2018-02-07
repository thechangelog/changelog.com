defmodule Changelog.Buffer.ContentTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.Buffer.Content
  alias ChangelogWeb.{Endpoint, NewsItemView, Router}

  describe "news_item_image" do
    test "defaults to nil" do
      assert is_nil(Content.news_item_image(nil))
    end

    test "returns nil when item has no image" do
      assert is_nil(Content.news_item_image(%{image: nil}))
    end

    test "calls NewsItemView.image_url when item has image" do
      item = %{image: "yes"}
      with_mock(NewsItemView, [image_url: fn(_, _) -> "url" end]) do
        assert Content.news_item_image(item) == "url"
        assert called(NewsItemView.image_url(item, :original))
      end
    end
  end

  describe "news_item_link" do
    test "returns item url when story is less than 20 words" do
      item = insert(:news_item, story: "This is too short")
      assert Content.news_item_link(item) == item.url
    end

    test "returns news item url when story is 20 words or more" do
      item = insert(:news_item, story: "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty")
      assert Content.news_item_link(item) == Router.Helpers.news_item_url(Endpoint, :show, NewsItemView.slug(item))
    end
  end

  describe "news_item_text" do
    test "defaults to empty string" do
      assert Content.news_item_text(nil) == ""
    end

    test "includes topic tags when available" do
      item = insert(:news_item)
      t1 = insert(:news_item_topic, news_item: item)
      t2 = insert(:news_item_topic, news_item: item)
      t3 = insert(:news_item_topic, news_item: item)
      assert Content.news_item_text(item) == "#{item.headline}\n\n##{t1.topic.slug} ##{t2.topic.slug} ##{t3.topic.slug}"
    end

    test "includes 'via' when news source has twitter handle" do
      source = insert(:news_source, twitter_handle: "wired")
      item = insert(:news_item, source: source)
      t1 = insert(:news_item_topic, news_item: item)
      assert Content.news_item_text(item) == "#{item.headline}\n\nvia @wired ##{t1.topic.slug}"
    end

    test "doesn't include 'via' when news source has no twitter handle" do
      source = insert(:news_source)
      item = insert(:news_item, source: source)
      t1 = insert(:news_item_topic, news_item: item)
      assert Content.news_item_text(item) == "#{item.headline}\n\n##{t1.topic.slug}"
    end
  end
end
