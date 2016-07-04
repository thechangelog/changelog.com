defmodule Changelog.Post do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "posts" do
    field :title, :string
    field :slug, :string
    field :published, :boolean, default: false
    field :published_at, Ecto.DateTime
    field :body, :string

    belongs_to :author, Changelog.Person
    has_many :post_channels, Changelog.PostChannel, on_delete: :delete_all
    has_many :channels, through: [:post_channels, :channel]

    timestamps
  end

  @required_fields ~w(title slug author_id)
  @optional_fields ~w(published published_at body)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> cast_assoc(:post_channels)
  end

  def published(query) do
    from p in query, where: p.published == true
  end

  def preload_all(model) do
    model
    |> Repo.preload(:author)
    |> Repo.preload([
      post_channels: {Changelog.PostChannel.by_position, :channel}
    ])
  end
end
