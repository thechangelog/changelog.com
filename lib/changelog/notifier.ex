defmodule Changelog.Notifier do
  alias Changelog.{Mailer, Episode, NewsItem, NewsItemComment, Slack}
  alias ChangelogWeb.Email

  def notify(item = %NewsItem{type: :audio}) do
    episode =
      item
      |> NewsItem.load_object()
      |> Map.get(:object)
      |> Episode.preload_all()

    deliver_guest_thanks_emails(episode)
    deliver_slack_new_episode_message(episode.podcast, item.url)
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
    parent  = NewsItemComment.preload_all(comment.parent)

    deliver_slack_new_comment_message(comment)

    if parent && parent.author != comment.author do
      deliver_comment_reply_email(parent.author, comment)
    end
  end

  defp deliver_author_email(nil, _item), do: false
  defp deliver_author_email(person, item) do
    if person.settings.email_on_authored_news do
      Email.authored_news_published(person, item) |> Mailer.deliver_later()
    end
  end

  defp deliver_comment_reply_email(nil, _reply), do: false
  defp deliver_comment_reply_email(person, reply) do
    if person.settings.email_on_comment_replies do
      Email.comment_reply(person, reply) |> Mailer.deliver_later()
    end
  end


  defp deliver_guest_thanks_emails(episode) do
    for eg <- Enum.filter(episode.episode_guests, &(&1.thanks)) do
      Email.guest_thanks(eg.person, episode) |> Mailer.deliver_later()
    end
  end

  defp deliver_slack_new_comment_message(comment) do
    message = Slack.Messages.new_comment(comment)
    Slack.Client.message("#news-comments", message)
  end

  defp deliver_slack_new_episode_message(podcast, url) do
    message = Slack.Messages.new_episode(podcast, url)
    Slack.Client.message("#main", message)
  end

  defp deliver_submitter_email(nil, _item), do: false
  defp deliver_submitter_email(person, item) do
    if person.settings.email_on_submitted_news do
      Email.submitted_news_published(person, item) |> Mailer.deliver_later()
    end
  end
end
