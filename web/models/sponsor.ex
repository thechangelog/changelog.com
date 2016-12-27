defmodule Changelog.Sponsor do
  use Changelog.Web, :model
  use Arc.Ecto.Schema

  alias Changelog.Regexp

  schema "sponsors" do
    field :name, :string
    field :description, :string
    field :website, :string
    field :github_handle, :string
    field :twitter_handle, :string

    field :color_logo, Changelog.ColorLogo.Type
    field :dark_logo, Changelog.DarkLogo.Type
    field :light_logo, Changelog.LightLogo.Type

    has_many :episode_sponsors, Changelog.EpisodeSponsor, on_delete: :delete_all

    timestamps()
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name description website github_handle twitter_handle))
    |> validate_required([:name])
    |> cast_attachments(params, ~w(color_logo dark_logo light_logo))
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> unique_constraint(:name)
  end

  def sponsorship_count(sponsor) do
    Repo.one from(e in Changelog.EpisodeSponsor,
      where: e.sponsor_id == ^sponsor.id,
      select: count(e.id))
  end
end
