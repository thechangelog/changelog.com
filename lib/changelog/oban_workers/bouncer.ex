defmodule Changelog.ObanWorkers.Bouncer do
  @moduledoc """
  This module defines the Oban worker for getting hard bounces/spam from CM and
  deleting the associated people records from the system
  """

  alias Changelog.{EventLog, ListKit, Newsletters, Person, Repo}
  alias ChangelogWeb.PersonView
  alias Craisin.Client

  use Oban.Worker, queue: :scheduled

  @impl Oban.Worker
  def perform(_job) do
    delete_bounces()
    delete_spam()

    :ok
  end

  def delete_bounces do
    bounced =
      Client.bounces()
      |> Enum.filter(&is_hard_bounce/1)
      |> Enum.map(&email_address/1)
      |> ListKit.compact()
      |> Enum.uniq()

    {deleted_count, _} = Person.with_email(bounced) |> Repo.delete_all()

    log("Deleted #{deleted_count} people from #{length(bounced)} hard bounced emails.")
  end

  def delete_spam do
    spam =
      Client.spam()
      |> Enum.map(&email_address/1)
      |> ListKit.compact()
      |> Enum.uniq()

    {deleted_count, _} = Person.with_email(spam) |> Repo.delete_all()

    log("Deleted #{deleted_count} people from #{length(spam)} emails marked as spam.")
  end

  def delete_unconfirmed do
    older_than = Timex.shift(Timex.today(), weeks: -1)
    people = Person.older_than(older_than) |> Person.needs_confirmation() |> Repo.all()

    results = Enum.map(people, fn person ->
      person = Person.preload_subscriptions(person)

      if PersonView.is_subscribed(person, Newsletters.nightly()) do
        false
      else
        log("Deleted #{person.id} #{person.name} (#{person.email})")
        Repo.delete!(person)
        true
      end
    end)

    true_count = results |> Enum.filter(&(&1)) |> length()
    false_count = results |> Enum.filter(&(!&1)) |> length()

    log("Deleted #{true_count} unconfirmed people older than #{older_than}. #{false_count} skipped.")
  end

  defp log(message), do: EventLog.insert(message, "Bouncer")

  defp is_hard_bounce(bounce) do
    bounce["BounceCategory"] == "Hard"
  end

  defp email_address(bounce) do
    recipient = bounce["Recipient"]

    case Regex.named_captures(~r/\<(?<email>.*?)\>/, recipient) do
      %{"email" => email} -> email
      _else -> nil
    end
  end
end
