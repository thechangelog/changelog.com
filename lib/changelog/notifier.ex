defmodule Changelog.Notifier do
  alias Changelog.{
    Episode,
    EpisodeRequest,
    NewsItem,
    NewsItemComment,
    Person,
    Podcast,
    Repo,
    Subscription,
    Slack,
    StringKit
  }

  alias Changelog.ObanWorkers.{MailDeliverer, SocialPoster}

  def notify(%NewsItem{feed_only: true}), do: false

  def notify(item = %NewsItem{type: :audio}) do
    episode =
      item
      |> NewsItem.load_object()
      |> Map.get(:object)
      |> Episode.preload_all()

    SocialPoster.queue(episode)

    deliver_episode_guest_thanks_emails(episode)
    deliver_episode_request_email(episode)
    deliver_podcast_subscription_emails(episode)
  end

  def notify(item = %NewsItem{status: :accepted}) do
    if StringKit.present?(item.message) do
      item
      |> NewsItem.preload_all()
      |> deliver_submitter_accepted_email()
    end
  end

  def notify(item = %NewsItem{status: :declined}) do
    if StringKit.present?(item.message) do
      item
      |> NewsItem.preload_all()
      |> deliver_submitter_decline_email()
    end
  end

  def notify(item = %NewsItem{}) do
    item = NewsItem.preload_all(item)

    if NewsItem.is_post(item) do
      post = item |> NewsItem.load_object() |> Map.get(:object)
      deliver_slack_new_post_message(post)
    end

    if item.submitter == item.author do
      deliver_submitter_email(item.submitter, item)
    else
      deliver_author_email(item.author, item)
      deliver_submitter_email(item.submitter, item)
    end
  end

  def notify(request = %EpisodeRequest{status: :declined}) do
    if StringKit.present?(request.message) do
      request
      |> EpisodeRequest.preload_all()
      |> deliver_request_decline_email()
    end
  end

  def notify(request = %EpisodeRequest{status: :failed}) do
    if StringKit.present?(request.message) do
      request
      |> EpisodeRequest.preload_all()
      |> deliver_request_fail_email()
    end
  end

  def notify(%EpisodeRequest{}), do: false

  def notify(comment = %NewsItemComment{approved: false}) do
    comment = NewsItemComment.preload_all(comment)
    moderators = ~w(jerod@changelog.com)

    for person <- moderators |> Person.with_email() |> Repo.all() do
      MailDeliverer.queue("comment_approval", %{"person" => person.id, "comment" => comment.id})
    end
  end

  def notify(comment = %NewsItemComment{approved: true}) do
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
      MailDeliverer.queue(mailer, %{"person" => recipient.id, "comment" => comment.id})
    end)
  end

  def notify(episode = %Episode{}) do
    episode = Episode.preload_all(episode)
    interested = ~w(jerod@changelog.com adam@changelog.com)

    for person <- interested |> Person.with_email() |> Repo.all() do
      deliver_episode_transcribed_email(person, episode)
    end

    subs =
      episode
      |> Subscription.on_episode()
      |> Subscription.subscribed()
      |> Subscription.preload_person()
      |> Repo.all()

    for sub <- subs do
      deliver_episode_transcribed_email(sub.person, episode)
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
      MailDeliverer.queue("authored_news_published", %{"item" => item.id})
    end
  end

  defp deliver_episode_guest_thanks_emails(episode) do
    for eg <- Enum.filter(episode.episode_guests, & &1.thanks) do
      MailDeliverer.queue("guest_thanks", %{"episode_guest" => eg.id})
    end
  end

  defp deliver_episode_request_email(%{episode_request: nil}), do: false

  defp deliver_episode_request_email(%{episode_request: request, guests: guests}) do
    request = EpisodeRequest.preload_submitter(request)

    if !Enum.member?(guests, request.submitter) do
      MailDeliverer.queue("episode_request_published", %{"request" => request.id})
    end
  end

  defp deliver_episode_transcribed_email(person, episode) do
    MailDeliverer.queue("episode_transcribed", %{"person" => person.id, "episode" => episode.id})
  end

  defp deliver_podcast_subscription_emails(episode) do
    podcast = Podcast.preload_subscriptions(episode.podcast)

    for subscription <- podcast.subscriptions do
      MailDeliverer.queue("episode_published", %{
        "subscription" => subscription.id,
        "episode" => episode.id,
        # lower than default priority (0) so transactionals send first
        "priority" => 1
      })
    end
  end

  defp deliver_slack_new_comment_message(comment) do
    message = Slack.Messages.new_comment(comment)
    Slack.Client.message("#news-comments", message)
  end

  defp deliver_slack_new_post_message(post) do
    message = Slack.Messages.new_post(post)
    Slack.Client.message("#main", message)
  end

  defp deliver_submitter_email(nil, _item), do: false

  defp deliver_submitter_email(person, item) do
    if person.settings.email_on_submitted_news do
      MailDeliverer.queue("submitted_news_published", %{"item" => item.id})
    end
  end

  defp deliver_submitter_accepted_email(item) do
    MailDeliverer.queue("submitted_news_accepted", %{"item" => item.id})
  end

  defp deliver_submitter_decline_email(item) do
    MailDeliverer.queue("submitted_news_declined", %{"item" => item.id})
  end

  defp deliver_request_decline_email(request) do
    MailDeliverer.queue("episode_request_declined", %{"request" => request.id})
  end

  defp deliver_request_fail_email(request) do
    MailDeliverer.queue("episode_request_failed", %{"request" => request.id})
  end
end
