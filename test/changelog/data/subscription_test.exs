defmodule Changelog.SubscriptionTest do
  use Changelog.DataCase

  alias Changelog.Subscription

  describe "subscribe/2 with news item" do
    setup do
      {:ok, person: insert(:person), item: insert(:news_item)}
    end

    test "when person has never subscribed", %{person: person, item: item} do
      {:ok, subscription} = Subscription.subscribe(person, item)
      assert subscription.person_id == person.id
      assert subscription.item_id == item.id
    end

    test "when person has unsubscribed", %{person: person, item: item} do
      insert(:unsubscribed_subscription_on_item, person: person, item: item)
      {:ok, subscription} = Subscription.subscribe(person, item)
      assert subscription.person_id == person.id
      assert subscription.item_id == item.id
      assert Repo.count(Subscription) == 1
    end

    test "when person is already subscribed", %{person: person, item: item} do
      insert(:subscription_on_item, person: person, item: item)
      {:ok, subscription} = Subscription.subscribe(person, item)
      assert subscription.person_id == person.id
      assert subscription.item_id == item.id
      assert Repo.count(Subscription) == 1
    end
  end

  describe "subscribe/2 with podcast" do
    setup do
      {:ok, person: insert(:person), podcast: insert(:podcast)}
    end

    test "when person has never subscribed", %{person: person, podcast: podcast} do
      {:ok, subscription} = Subscription.subscribe(person, podcast)
      assert subscription.person_id == person.id
      assert subscription.podcast_id == podcast.id
    end

    test "when person has unsubscribed", %{person: person, podcast: podcast} do
      insert(:unsubscribed_subscription_on_podcast, person: person, podcast: podcast)
      {:ok, subscription} = Subscription.subscribe(person, podcast)
      assert subscription.person_id == person.id
      assert subscription.podcast_id == podcast.id
      assert Repo.count(Subscription) == 1
    end

    test "when person is already subscribed", %{person: person, podcast: podcast} do
      insert(:subscription_on_podcast, person: person, podcast: podcast)
      {:ok, subscription} = Subscription.subscribe(person, podcast)
      assert subscription.person_id == person.id
      assert subscription.podcast_id == podcast.id
      assert Repo.count(Subscription) == 1
    end
  end

  describe "unsubcribe/2 with item" do
    setup do
      {:ok, person: insert(:person), item: insert(:news_item)}
    end

    test "when person has never subscribed", %{person: person, item: item} do
      :ok = Subscription.unsubscribe(person, item)
      assert Repo.count(Subscription) == 0
    end

    test "when person has already unsubscribed", %{person: person, item: item} do
      insert(:unsubscribed_subscription_on_item, person: person, item: item)
      :ok = Subscription.unsubscribe(person, item)
      assert Repo.count(Subscription) == 1
      assert Repo.count(Subscription.unsubscribed) == 1
    end

    test "when person is subscribed", %{person: person, item: item} do
      insert(:subscription_on_item, person: person, item: item)
      :ok = Subscription.unsubscribe(person, item)
      assert Repo.count(Subscription) == 1
      assert Repo.count(Subscription.unsubscribed) == 1
    end
  end

  describe "unsubcribe/2 with podcast" do
    setup do
      {:ok, person: insert(:person), podcast: insert(:podcast)}
    end

    test "when person has never subscribed", %{person: person, podcast: podcast} do
      :ok = Subscription.unsubscribe(person, podcast)
      assert Repo.count(Subscription) == 0
    end

    test "when person has already unsubscribed", %{person: person, podcast: podcast} do
      insert(:unsubscribed_subscription_on_podcast, person: person, podcast: podcast)
      :ok = Subscription.unsubscribe(person, podcast)
      assert Repo.count(Subscription) == 1
      assert Repo.count(Subscription.unsubscribed) == 1
    end

    test "when person is subscribed", %{person: person, podcast: podcast} do
      insert(:subscription_on_podcast, person: person, podcast: podcast)
      :ok = Subscription.unsubscribe(person, podcast)
      assert Repo.count(Subscription) == 1
      assert Repo.count(Subscription.unsubscribed) == 1
    end
  end
end
