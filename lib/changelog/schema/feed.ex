defmodule Changelog.Feed do
  use Changelog.Schema

  alias Changelog.{ListKit, Files, FeedStat, Person}

  schema "feeds" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :title_format, :string
    field :plusplus, :boolean, default: false
    field :autosub, :boolean, default: true
    field :starts_on, :date
    field :refreshed_at, :utc_datetime
    field :cover, Files.Cover.Type

    field :agents, {:array, :string}, default: []
    field :podcast_ids, {:array, :integer}, default: []
    field :person_ids, {:array, :integer}, default: []

    belongs_to :owner, Person

    has_many :feed_stats, FeedStat

    timestamps()
  end

  def get_by_slug(slug), do: Repo.get_by(__MODULE__, slug: slug)

  def get_by_slug!(slug), do: Repo.get_by!(__MODULE__, slug: slug)

  def with_podcast_id(query \\ __MODULE__, id),
    do: from(q in query, where: fragment("? = ANY(?)", ^id, q.podcast_ids))

  def file_changeset(feed, attrs \\ %{}),
    do: cast_attachments(feed, attrs, [:cover], allow_urls: true)

  def insert_changeset(feed, attrs \\ %{}) do
    feed
    |> cast(
      attrs,
      ~w(name description title_format plusplus autosub starts_on podcast_ids person_ids owner_id)a
    )
    |> put_random_slug()
    |> validate_required([:name, :slug, :owner_id])
    |> unique_constraint(:slug)
  end

  def update_changeset(feed, attrs \\ %{}) do
    feed
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def preload_all(feed) do
    feed
    |> preload_owner()
  end

  def preload_owner(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :owner)
  def preload_owner(feed), do: Repo.preload(feed, :owner)

  def refresh!(feed) do
    # using update_all to avoid auto `updated_at` change
    query = from(q in __MODULE__, where: q.id == ^feed.id)
    Repo.update_all(query, set: [refreshed_at: now_in_seconds()])
  end

  def update_agents(feed) do
    stat =
      feed
      |> assoc(:feed_stats)
      |> FeedStat.newest_first()
      |> FeedStat.limit(1)
      |> Repo.one()

    if stat do
      agents = Enum.map(stat.agents, fn {name, _data} -> name end)

      new_agents = ListKit.uniq_merge(feed.agents || [], agents)

      feed
      |> change(%{agents: new_agents})
      |> Repo.update!()
    else
      feed
    end
  end

  def starts_on_time(%{starts_on: nil}), do: nil

  def starts_on_time(%{starts_on: date}) do
    Timex.beginning_of_day(date)
  end

  defp put_random_slug(changeset, length \\ 16)

  defp put_random_slug(changeset = %{data: %{slug: nil}}, length) do
    put_change(changeset, :slug, :binary.encode_hex(:crypto.strong_rand_bytes(length)))
  end

  defp put_random_slug(changeset, _length), do: changeset
end
