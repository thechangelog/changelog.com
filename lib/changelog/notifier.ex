defmodule Changelog.Notifier do
  alias Changelog.{Mailer, Episode, NewsItem, Slack}
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

  defp deliver_author_email(person, _item) when is_nil(person), do: false
  defp deliver_author_email(person, item) do
    if person.settings.email_on_authored_news do
      Email.authored_news_published(person, item) |> Mailer.deliver_later
    end
  end

  defp deliver_guest_thanks_emails(episode) do
    for eg <- Enum.filter(episode.episode_guests, &(&1.thanks)) do
      Email.guest_thanks(eg.person, episode) |> Mailer.deliver_later()
    end
  end

  defp deliver_slack_new_episode_message(podcast, url) do
    message = Slack.Messages.new_episode(podcast, url)
    Slack.Client.message("#main", message)
  end

  defp deliver_submitter_email(person, _item) when is_nil(person), do: false
  defp deliver_submitter_email(person, item) do
    if person.settings.email_on_submitted_news do
      Email.submitted_news_published(person, item) |> Mailer.deliver_later
    end
  end
end
