defmodule Changelog.ObanWorkers.Bouncer do
  @moduledoc """
  This module defines the Oban worker for getting hard bounces/spam from CM and
  deleting the associated people records from the system
  """
  require Logger

  alias Changelog.{ListKit, Person, Repo}
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

    Logger.info "Bouncer deleted #{deleted_count} from #{length(bounced)} hard bounced emails."
  end

  def delete_spam do
    spam =
      Client.spam()
      |> Enum.map(&email_address/1)
      |> ListKit.compact()
      |> Enum.uniq()

    {deleted_count, _} = Person.with_email(spam) |> Repo.delete_all()

    Logger.info "Bouncer deleted #{deleted_count} from #{length(spam)} emails marked as spam."
  end

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
