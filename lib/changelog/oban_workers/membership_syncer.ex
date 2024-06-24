defmodule Changelog.ObanWorkers.MembershipSyncer do
  use Oban.Worker, queue: :scheduled

  alias Changelog.{EventLog, Faker, Membership, Person, Repo}

  @impl Oban.Worker
  def perform(_job) do
    for sub <- Changelog.Stripe.subscriptions() do
      if membership = find_membership(sub) do
        update_membership(membership, sub)
      else
        customer = get_stripe_customer(sub)
        person = find_or_insert_person(customer)
        insert_membership(sub, person)
      end
    end

    :ok
  end

  def queue do
    %{} |> new() |> Oban.insert()
  end

  def insert_membership(sub, person) do
    params = %{
      status: sub.status,
      subscription_id: sub.id,
      person_id: person.id,
      started_at: DateTime.from_unix!(sub.start_date),
      supercast_id: sub.metadata["user_id"]
    }

    changeset = Membership.changeset(%Membership{}, params)

    case Repo.insert(changeset) do
      {:ok, membership} ->
        EventLog.insert("Created membership for person with email: #{person.email}", "Striper")
        membership

      {:error, _changeset} ->
        EventLog.insert(
          "Failed to create membership for person with email: #{person.email} (#{sub.status})",
          "Striper"
        )

        nil
    end
  end

  def update_membership(membership, sub) do
    changeset = Membership.changeset(membership, %{status: sub.status})

    if Enum.any?(changeset.changes) do
      EventLog.insert(
        "Updated membership ##{membership.id}: #{inspect(changeset.changes)}",
        "Striper"
      )

      Repo.update(changeset)
    else
      {:ok, membership}
    end
  end

  defp get_stripe_customer(sub) do
    customer = Changelog.Stripe.customer(sub.customer)

    if is_nil(customer.email) do
      customer
      |> Map.put(:email, customer.metadata["gift_from_email"])
      |> Map.put(:name, customer.metadata["gift_from_name"])
    else
      customer
    end
  end

  defp find_membership(%{id: id}) do
    id |> Membership.with_subscription_id() |> Repo.one()
  end

  defp find_or_insert_person(customer) do
    find_person(customer) || insert_person(customer)
  end

  defp find_person(%{email: email}) do
    email |> Person.with_email() |> Repo.one()
  end

  defp insert_person(%{email: email, name: name, created: created_at}) do
    person =
      if name do
        %Person{name: name, handle: Faker.handle(name)}
      else
        Person.with_fake_data()
      end

    attrs = %{
      email: email,
      public_profile: false,
      joined_at: DateTime.from_unix!(created_at)
    }

    changeset = Person.insert_changeset(person, attrs)

    case Repo.insert(changeset) do
      {:ok, person} ->
        EventLog.insert("Created person with email: #{email}", "Striper")
        person

      {:error, _changeset} ->
        nil
    end
  end
end
