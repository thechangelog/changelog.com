defmodule Changelog.ObanWorkers.EpisodePublishedMailer do
  use Oban.Worker, queue: :email

  alias Changelog.{Episode, Mailer, Repo, Subscription}
  alias ChangelogWeb.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"subscription_id" => s_id, "episode_id" => e_id}}) do
    subscription = Subscription |> Repo.get(s_id) |> Subscription.preload_all()
    episode = Episode |> Repo.get(e_id) |> Episode.preload_all()

    subscription
    |> Email.episode_published(episode)
    |> Mailer.deliver_now()

    :ok
  end

  def enqueue(%Subscription{id: s_id}, %Episode{id: e_id}) do
    %{"subscription_id" => s_id, "episode_id" => e_id}
    |> new()
    |> Oban.insert()
  end
end
