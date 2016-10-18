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
    |> cast_assoc(:post_channels)
  end

  def published(query \\ __MODULE__) do
    from p in query, where: p.published == true
  end

  def newest_first(query \\ __MODULE__) do
    from p in query, order_by: [desc: p.published_at]
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
end
