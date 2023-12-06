defmodule Changelog.EpisodeRequest do
  use Changelog.Schema

  alias Changelog.{Episode, Podcast, Person}

  defenum(Status, declined: -1, fresh: 0, pending: 1, failed: 2)

  schema "episode_requests" do
    field :status, Status, default: :fresh

    field :hosts, :string
    field :guests, :string
    field :topics, :string
    field :pitch, :string
    field :pronunciation, :string
    field :message, :string, default: ""

    belongs_to :podcast, Podcast
    belongs_to :submitter, Person

    has_one :episode, Episode, foreign_key: :request_id

    timestamps()
  end

  def fresh(query \\ __MODULE__), do: from(q in query, where: q.status == ^:fresh)
  def active(query \\ __MODULE__), do: from(q in query, where: q.status in [^:fresh, ^:pending])
  def pending(query \\ __MODULE__), do: from(q in query, where: q.status == ^:pending)
  def declined(query \\ __MODULE__), do: from(q in query, where: q.status == ^:declined)
  def failed(query \\ __MODULE__), do: from(q in query, where: q.status == ^:failed)

  def with_message(query \\ __MODULE__), do: from(q in query, where: q.message != "")

  def with_episode(query \\ __MODULE__) do
    from(q in query, join: e in Episode, on: q.id == e.request_id)
  end

  def with_published_episode(query \\ __MODULE__) do
    from(q in query, join: e in Episode, on: q.id == e.request_id, where: e.published)
  end

  def with_unpublished_episode(query \\ __MODULE__) do
    from(q in query, join: e in Episode, on: q.id == e.request_id, where: not(e.published))
  end

  def sans_episode(query \\ __MODULE__) do
    from(
      q in query,
      left_join: e in Episode,
      on: q.id == e.request_id,
      where: is_nil(e.id)
    )
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(podcast_id submitter_id hosts guests topics pitch pronunciation)a)
    |> validate_required([:podcast_id, :submitter_id, :pitch])
    |> foreign_key_constraint(:podcast_id)
  end

  def submission_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(podcast_id submitter_id hosts guests topics pitch pronunciation)a)
    |> validate_required([:podcast_id, :submitter_id, :pitch])
    |> validate_length(:topics, max: 140, message: "Keep it tweet size, please (OG 140 chars)")
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

  def is_undecided(%{episode: episode}) when is_map(episode), do: false
  def is_undecided(%{status: status}), do: Enum.member?(~w(fresh pending)a, status)

  def is_pendable(%{episode: episode}) when is_map(episode), do: false
  def is_pendable(%{status: status}), do: Enum.member?(~w(fresh)a, status)

  def is_archived(%{status: status}), do: Enum.member?(~w(failed declined)a, status)

  def is_complete(%{episode: episode}) when is_map(episode), do: episode.published
  def is_complete(%{episode: nil}), do: false

  def decline!(request), do: update_status!(request, :declined)
  def decline!(request, ""), do: decline!(request)

  def decline!(request, message) do
    request
    |> change(%{message: message})
    |> update_status!(:declined)
  end

  def fail!(request), do: update_status!(request, :failed)
  def fail!(request, ""), do: fail!(request)

  def fail!(request, message) do
    request
    |> change(%{message: message})
    |> update_status!(:failed)
  end

  def pend!(request), do: update_status!(request, :pending)

  defp update_status!(request, status) do
    request |> change(%{status: status}) |> Repo.update!()
  end
end
