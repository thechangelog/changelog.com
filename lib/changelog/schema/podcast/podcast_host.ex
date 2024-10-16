defmodule Changelog.PodcastHost do
  use Changelog.Schema

  alias Changelog.{Person, Podcast}

  schema "podcast_hosts" do
    field :position, :integer
    field :retired, :boolean, default: false
    field :delete, :boolean, virtual: true

    belongs_to :person, Person
    belongs_to :podcast, Podcast

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(position retired podcast_id person_id delete)a)
    |> validate_required([:position])
    |> foreign_key_constraint(:person_id)
    |> foreign_key_constraint(:podcast_id)
    |> mark_for_deletion()
  end

  def active_host(query \\ __MODULE__) do
    from(q in query,
      where: not(q.retired),
      join: p in assoc(q, :person),
      distinct: q.person_id)
  end

  def retired_host(query \\ __MODULE__), do: from(q in query, where: q.retired, distinct: q.person_id)

  def active_podcast(query \\ __MODULE__) do
    from(q in query, join: p in assoc(q, :podcast), where: p.status in [^:soon, ^:publishing])
  end

  def retired_podcast(query \\ __MODULE__) do
    from(q in query, join: p in assoc(q, :podcast), where: p.status == ^:inactive)
  end

  def retired_host_or_podcast(query \\ __MODULE__) do
    from(q in query,
      join: p in assoc(q, :podcast),
      where: q.retired,
      or_where: p.status == ^:inactive,
      distinct: q.person_id)
  end
end
