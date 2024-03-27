defmodule Changelog.Feed do
  use Changelog.Schema

  alias Changelog.{Files, Person}

  schema "feeds" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :plusplus, :boolean, default: false
    field :autosub, :boolean, default: true
    field :starts_at, :utc_datetime
    field :cover, Files.Cover.Type

    field :podcast_ids, {:array, :integer}, default: []
    field :person_ids, {:array, :integer}, default: []

    belongs_to :owner, Person

    timestamps()
  end

  def file_changeset(feed, attrs \\ %{}),
    do: cast_attachments(feed, attrs, [:cover])

  def insert_changeset(feed, attrs \\ %{}) do
    feed
    |> cast(
      attrs,
      ~w(name description plusplus autosub starts_at podcast_ids person_ids owner_id)a
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

  defp put_random_slug(changeset, length \\ 16) do
    put_change(changeset, :slug, :binary.encode_hex(:crypto.strong_rand_bytes(length)))
  end
end
