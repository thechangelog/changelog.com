defmodule Changelog.Membership do
  use Changelog.Schema

  alias Changelog.Person

  defenum(Status, canceled: 0, active: 1)

  schema "memberships" do
    field :status, Status, default: :active
    field :subscription_id, :string
    field :anonymous, :boolean, default: false

    belongs_to :person, Person

    timestamps()
  end

  def active(query \\ __MODULE__), do: from(q in query, where: q.status == ^:active)
  def canceled(query \\ __MODULE__), do: from(q in query, where: q.status == ^:canceled)

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
    |> cast(attrs, ~w(subscription_id person_id status)a)
    |> validate_required(~w(subscription_id person_id status)a)
    |> unique_constraint(:subscription_id)
  end
end
