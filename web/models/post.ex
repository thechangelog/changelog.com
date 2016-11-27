defmodule Changelog.Post do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "posts" do
    field :title, :string

    field :slug, :string
    field :guid, :string

    field :tldr, :string
    field :body, :string

    field :published, :boolean, default: false
    field :published_at, Timex.Ecto.DateTime

    belongs_to :author, Changelog.Person
    has_many :post_channels, Changelog.PostChannel, on_delete: :delete_all
    has_many :channels, through: [:post_channels, :channel]

    timestamps
  end

  @required_fields ~w(title slug author_id)
  @optional_fields ~w(published published_at body tldr)

  def changeset(post, params \\ %{}) do
    post
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> validate_published_has_published_at
    |> cast_assoc(:post_channels)
  end

  def published(query \\ __MODULE__) do
    from p in query,
      where: p.published == true,
      where: p.published_at <= ^Timex.now
  end

  def scheduled(query \\ __MODULE__) do
    from p in query,
      where: p.published == true,
      where: p.published_at > ^Timex.now
  end

  def unpublished(query \\ __MODULE__) do
    from p in query, where: p.published == false
  end

  def newest_first(query \\ __MODULE__, field \\ :published_at) do
    from e in query, order_by: [desc: ^field]
  end

  def newest_last(query \\ __MODULE__, field \\ :published_at) do
    from e in query, order_by: [asc: ^field]
  end

  def limit(query, count) do
    from e in query, limit: ^count
  end

  def is_public(post, as_of \\ Timex.now) do
    post.published && post.published_at <= as_of
  end

  def preload_all(post) do
    post
    |> preload_author
    |> preload_channels
  end

  def preload_author(post) do
    post
    |> Repo.preload(:author)
  end

  def preload_channels(post) do
    post
    |> Repo.preload(post_channels: {Changelog.PostChannel.by_position, :channel})
    |> Repo.preload(:channels)
  end

  defp validate_published_has_published_at(changeset) do
    published = get_field(changeset, :published)
    published_at = get_field(changeset, :published_at)

    if published && is_nil(published_at) do
      add_error(changeset, :published_at, "can't be blank when published")
    else
      changeset
    end
  end
end
