defmodule Changelog.EpisodeRequest do
  use Changelog.Schema

  alias Changelog.{Episode, Podcast, Person}

  defenum Status, declined: -1, submitted: 0, pending: 1, published: 2

  schema "episode_requests" do
    field :status, Status, default: :submitted

    field :hosts, :string
    field :guests, :string
    field :topics, :string
    field :pitch, :string
    field :pronunciation, :string

    belongs_to :podcast, Podcast
    belongs_to :submitter, Person
    belongs_to :episode, Episode

    timestamps()
  end

  def declined(query \\ __MODULE__), do: from(q in query, where: q.status == ^:declined)
  def pending(query \\ __MODULE__), do: from(q in query, where: q.status == ^:pending)
  def published(query \\ __MODULE__), do: from(q in query, where: q.status == ^:published)
  def submitted(query \\ __MODULE__), do: from(q in query, where: q.status == ^:submitted)

  def submission_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(podcast_id submitter_id hosts guests topics pitch pronunciation)a)
    |> validate_required([:podcast_id, :submitter_id, :pitch])
    |> foreign_key_constraint(:podcast_id)
  end
end
