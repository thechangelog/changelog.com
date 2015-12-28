defmodule Changelog.Podcast do
  use Changelog.Web, :model

  schema "podcasts" do
    field :name, :string
    field :slug, :string
    field :description, :string
    field :vanity_domain, :string
    field :keywords, :string
    field :twitter_handle, :string

    timestamps
  end

  @required_fields ~w(name slug)
  @optional_fields ~w(vanity_domain description keywords twitter_handle)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:slug, Changelog.Regexp.slug, message: Changelog.Regexp.slug_message)
    |> unique_constraint(:slug)
  end
end
