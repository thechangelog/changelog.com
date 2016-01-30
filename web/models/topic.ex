defmodule Changelog.Topic do
  use Changelog.Web, :model

  alias Changelog.Regexp

  schema "topics" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :website, :string

    timestamps
  end

  @required_fields ~w(name slug)
  @optional_fields ~w(description website)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
  end
end
