defmodule Changelog.NotifierTest do
  use Changelog.DataCase
  use Bamboo.Test

  alias Changelog.Notifier
  alias ChangelogWeb.Email

  describe "notify" do
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
