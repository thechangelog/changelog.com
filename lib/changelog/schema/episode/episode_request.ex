defmodule Changelog.EpisodeRequest do
  use Changelog.Schema

  alias Changelog.{Episode, Podcast, Person}

  defenum Status, declined: -1, fresh: 0, pending: 1

  schema "episode_requests" do
    field :status, Status, default: :fresh

    field :hosts, :string
    field :guests, :string
    field :topics, :string
    field :pitch, :string
    field :pronunciation, :string

    belongs_to :podcast, Podcast
    belongs_to :submitter, Person

    has_one :episode, Episode, foreign_key: :request_id

    timestamps()
  end

  def fresh(query \\ __MODULE__),        do: from(q in query, where: q.status == ^:fresh)
  def active(query \\ __MODULE__),       do: from(q in query, where: q.status in [^:fresh, ^:pending])
  def pending(query \\ __MODULE__),      do: from(q in query, where: q.status == ^:pending)
  def declined(query \\ __MODULE__),     do: from(q in query, where: q.status == ^:declined)

  def with_episode(query \\ __MODULE__), do: from(q in query, join: e in Episode, on: q.id == e.request_id)
  def sans_episode(query \\ __MODULE__), do: from(q in query, left_join: e in Episode, on: q.id == e.request_id, where: is_nil(e.id))

  def submission_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(podcast_id submitter_id hosts guests topics pitch pronunciation)a)
    |> validate_required([:podcast_id, :submitter_id, :pitch])
    |> foreign_key_constraint(:podcast_id)
  end

  def preload_all(request) do
    request
    |> preload_episode()
    |> preload_podcast()
    |> preload_submitter()
  end

  def preload_episode(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :episode)
  def preload_episode(request), do: Repo.preload(request, :episode)

  def preload_podcast(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :podcast)
  def preload_podcast(request), do: Repo.preload(request, :podcast)

  def preload_submitter(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :submitter)
  def preload_submitter(request), do: Repo.preload(request, :submitter)

  def decline!(request), do: request |> change(%{status: :declined}) |> Repo.update!()
  def pend!(request), do: request |> change(%{status: :pending}) |> Repo.update!()
end
