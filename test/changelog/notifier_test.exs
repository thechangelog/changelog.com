defmodule Changelog.NotifierTest do
  use Changelog.DataCase
  use Bamboo.Test

  import Mock

  alias Changelog.{Notifier, Slack}
  alias ChangelogWeb.Email

  describe "notify with news item comment" do
    setup_with_mocks([
      {Slack.Client, [], [message: fn(_, _) -> true end]}
    ]) do
      :ok
    end

    test "when comment has no parent" do
      comment = insert(:news_item_comment)
      Notifier.notify(comment)
      assert_no_emails_delivered()
      assert called Slack.Client.message("#news-comments", :_)
    end

    test "when comment is a reply and parent author has notifications enabled" do
      comment = insert(:news_item_comment)
      reply = insert(:news_item_comment, news_item: comment.news_item, parent: comment)
      Notifier.notify(reply)
      assert_delivered_email Email.comment_reply(reply.parent.author, reply)
      assert called Slack.Client.message("#news-comments", :_)
    end

    test "when comment is a reply to own comment" do
      person = insert(:person)
      comment = insert(:news_item_comment, author: person)
      reply = insert(:news_item_comment, news_item: comment.news_item, parent: comment, author: person)
      Notifier.notify(reply)
      assert_no_emails_delivered()
      assert called Slack.Client.message("#news-comments", :_)
    end

    test "when comment is a reply and parent author has notifications disabled" do
      person = insert(:person, settings: %{email_on_comment_replies: false})
      comment = insert(:news_item_comment, author: person)
      reply = insert(:news_item_comment, news_item: comment.news_item, parent: comment)
      Notifier.notify(reply)
      assert_no_emails_delivered()
      assert called Slack.Client.message("#news-comments", :_)
    end
  end

  describe "notify with episode item" do
    setup_with_mocks([
      {Slack.Client, [], [message: fn(_, _) -> true end]}
    ]) do
      :ok
    end

    test "when episode has no guests" do
      episode = insert(:published_episode)
      item = episode |> episode_news_item() |> insert()
      Notifier.notify(item)
      assert_no_emails_delivered()
      assert called Slack.Client.message("#main", :_)
    end

    test "when episode has guests but none of them have 'thanks' set" do
      g1 = insert(:person)
      g2 = insert(:person)
      episode = insert(:published_episode)
      insert(:episode_guest, episode: episode, person: g1, thanks: false)
      insert(:episode_guest, episode: episode, person: g2, thanks: false)
      item = episode |> episode_news_item() |> insert()

      Notifier.notify(item)
      assert_no_emails_delivered()
      assert called Slack.Client.message("#main", :_)
    end

    test "when episode has guests and some of them have 'thanks' set" do
      g1 = insert(:person)
      g2 = insert(:person)
      g3 = insert(:person)
      episode = insert(:published_episode)
      insert(:episode_guest, episode: episode, person: g1, thanks: false)
      insert(:episode_guest, episode: episode, person: g2, thanks: true)
      insert(:episode_guest, episode: episode, person: g3, thanks: true)
      item = episode |> episode_news_item() |> insert()

      Notifier.notify(item)
      assert_delivered_email Email.guest_thanks(g2, episode)
      assert_delivered_email Email.guest_thanks(g3, episode)
      assert called Slack.Client.message("#main", :_)
    end
  end

  describe "notify with regular item" do
    test "when item has no submitter or author" do
      item = insert(:news_item)
      Notifier.notify(item)
      assert_no_emails_delivered()
    end

    test "when submitter has email notifications enabled" do
      person = insert(:person, settings: %{email_on_submitted_news: true})
      item = insert(:news_item, submitter: person)
      Notifier.notify(item)
      assert_delivered_email Email.submitted_news_published(person, item)
    end

    test "when submitter has email notifications disabled" do
      person = insert(:person, settings: %{email_on_submitted_news: false})
      item = insert(:news_item, submitter: person)
      Notifier.notify(item)
      assert_no_emails_delivered()
    end

    test "when submitter and author are same person, notifications enabled" do
      person = insert(:person, settings: %{email_on_submitted_news: true})
      item = insert(:news_item, submitter: person, author: person)
      Notifier.notify(item)
      assert_delivered_email Email.submitted_news_published(person, item)
      refute_delivered_email Email.authored_news_published(person, item)
    end

    test "when author has email notifications enabled" do
      person = insert(:person, settings: %{email_on_authored_news: true})
      item = insert(:news_item, author: person)
      Notifier.notify(item)
      assert_delivered_email Email.authored_news_published(person, item)
    end

    test "when author has email notifications disabled" do
      person = insert(:person, settings: %{email_on_authored_news: false})
      item = insert(:news_item, author: person)
      Notifier.notify(item)
      assert_no_emails_delivered()
    end

    test "when submitter and author both have notifications enabled" do
      submitter = insert(:person, settings: %{email_on_submitted_news: true})
      author = insert(:person, settings: %{email_on_authored_news: true})
      item = insert(:news_item, author: author, submitter: submitter)
      Notifier.notify(item)
      assert_delivered_email Email.authored_news_published(author, item)
      assert_delivered_email Email.submitted_news_published(submitter, item)
    end
  end
end
