defmodule Changelog.Membership do
  use Changelog.Schema

  alias Changelog.Person

  schema "memberships" do
    field :status, :string
    field :subscription_id, :string
    field :supercast_id, :string
    field :anonymous, :boolean, default: false
    field :started_at, :utc_datetime

    belongs_to :person, Person

    timestamps()
  end

  def active(query \\ __MODULE__),
    do: from(q in query, where: q.status in [^"active", ^"past_due"])

  def inactive(query \\ __MODULE__),
    do: from(q in query, where: q.status in [^"canceled", ^"unpaid", ^"incomplete_expired"])

  def unknown(query \\ __MODULE__),
    do:
      from(q in query,
        where:
          q.status not in [^"active", ^"past_due", ^"canceled", ^"unpaid", ^"incomplete_expired"]
      )

  def with_subscription_id(query \\ __MODULE__, id),
    do: from(q in query, where: q.subscription_id == ^id)

  def preload_person(query = %Ecto.Query{}) do
    Ecto.Query.preload(query, :person)
  end

  def preload_person(membership) do
    Repo.preload(membership, :person)
  end

  def changeset(membership, attrs \\ %{}) do
    membership
    |> cast(attrs, ~w(subscription_id person_id status supercast_id started_at)a)
    |> validate_required(~w(subscription_id person_id status)a)
    |> unique_constraint(:subscription_id)
  end
end
