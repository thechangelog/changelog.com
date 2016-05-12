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

    timestamps
  end

  @required_fields ~w(title slug author_id)
  @optional_fields ~w(published published_at body)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
  end
end
