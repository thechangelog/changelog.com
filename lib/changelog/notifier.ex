defmodule Changelog.Notifier do
  alias Changelog.{
    Episode,
    Mailer,
    NewsItem,
    NewsItemComment,
    Person,
    Podcast,
    Repo,
    Subscription,
    Slack
  }

  alias ChangelogWeb.Email

  def notify(%NewsItem{feed_only: true}), do: false

  def notify(item = %NewsItem{type: :audio}) do
    episode =
      item
      |> NewsItem.load_object()
      |> Map.get(:object)
      |> Episode.preload_all()

    deliver_episode_guest_thanks_emails(episode)
    deliver_podcast_subscription_emails(episode)
    deliver_slack_new_episode_message(episode, item.url)
  end

  def notify(item = %NewsItem{}) do
    item = NewsItem.preload_all(item)

    if item.submitter == item.author do
      deliver_submitter_email(item.submitter, item)
    else
      deliver_author_email(item.author, item)
      deliver_submitter_email(item.submitter, item)
    end
  end

  def notify(comment = %NewsItemComment{}) do
    comment = NewsItemComment.preload_all(comment)

    deliver_slack_new_comment_message(comment)

    # these functions all return lists of tuples where each tuple consists of:
    # {person, email_recipient (person or subscription), mailer_fn}
    (list_of_comment_reply_recipients(comment) ++
       list_of_comment_mention_recipients(comment) ++
       list_of_comment_subscriptions(comment))
    |> List.flatten()
    |> Enum.uniq_by(fn {person, _recipient, _mailer} -> person end)
    |> Enum.reject(fn {person, _recipient, _mailer} ->
      Subscription.is_unsubscribed(person, comment.news_item)
    end)
    |> Enum.each(fn {_person, recipient, mailer} ->
      Email
      |> apply(mailer, [recipient, comment])
      |> Mailer.deliver_later()
    end)
  end

  def notify(episode = %Episode{}) do
    episode = Episode.preload_all(episode)
    interested = ~w(jerod@changelog.com adam@changelog.com)

    for person <- interested |> Person.with_email() |> Repo.all() do
      deliver_episode_transcribed_email(person, episode)
    end
  end

  defp list_of_comment_mention_recipients(comment) do
    comment
    |> NewsItemComment.mentioned_people()
    |> Enum.filter(& &1.settings.email_on_comment_mentions)
    |> Enum.map(fn person ->
      {person, person, :comment_mention}
    end)
  end

  defp list_of_comment_reply_recipients(%{parent: nil}), do: []

  defp list_of_comment_reply_recipients(reply = %{parent: parent}) do
    parent = NewsItemComment.preload_all(parent).author
    replyer = reply.author

    if parent != replyer && parent.settings.email_on_comment_replies do
      [{parent, parent, :comment_reply}]
    else
      []
    end
  end

  defp list_of_comment_subscriptions(comment) do
    comment.news_item
    |> Subscription.on_item()
    |> Subscription.subscribed()
    |> Subscription.preload_person()
    |> Repo.all()
    |> Enum.reject(&(&1.person == comment.author))
    |> Enum.map(fn subscription ->
      {subscription.person, subscription, :comment_subscription}
    end)
  end

  defp deliver_author_email(nil, _item), do: false

  defp deliver_author_email(person, item) do
    if person.settings.email_on_authored_news do
      person
      |> Email.authored_news_published(item)
      |> Mailer.deliver_later()
    end
  end

  defp deliver_episode_guest_thanks_emails(episode) do
    for eg <- Enum.filter(episode.episode_guests, & &1.thanks) do
      eg.person
      |> Email.guest_thanks(episode)
      |> Mailer.deliver_later()
    end
  end

  defp deliver_episode_transcribed_email(person, episode) do
    person |> Email.episode_transcribed(episode) |> Mailer.deliver_later()
  end

  defp deliver_podcast_subscription_emails(episode) do
    podcast = Podcast.preload_subscriptions(episode.podcast)

    for subscription <- podcast.subscriptions do
      subscription
      |> Subscription.preload_all()
      |> Email.episode_published(episode)
      |> Mailer.deliver_later()
    end
  end

  defp deliver_slack_new_comment_message(comment) do
    message = Slack.Messages.new_comment(comment)
    Slack.Client.message("#news-comments", message)
  end

  defp deliver_slack_new_episode_message(episode, url) do
    message = Slack.Messages.new_episode(episode, url)
    Slack.Client.message("#main", message)
  end

  defp deliver_submitter_email(nil, _item), do: false

  defp deliver_submitter_email(person, item) do
    if person.settings.email_on_submitted_news do
      person
      |> Email.submitted_news_published(item)
      |> Mailer.deliver_later()
    end
  end
end
