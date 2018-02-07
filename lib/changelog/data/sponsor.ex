defmodule Changelog.Sponsor do
  use Changelog.Data

  alias Changelog.{Benefit, Files, EpisodeSponsor, Regexp}

  schema "sponsors" do
    field :name, :string
    field :description, :string
    field :website, :string
    field :github_handle, :string
    field :twitter_handle, :string

    field :avatar, Files.Avatar.Type
    field :color_logo, Files.ColorLogo.Type
    field :dark_logo, Files.DarkLogo.Type
    field :light_logo, Files.LightLogo.Type

    has_many :benefits, Benefit, on_delete: :delete_all
    has_many :episode_sponsors, EpisodeSponsor, on_delete: :delete_all

    timestamps()
  end

  def file_changeset(sponsor, attrs \\ %{}) do
    cast_attachments(sponsor, attrs, ~w(avatar color_logo dark_logo light_logo), allow_urls: true)
  end

  def insert_changeset(sponsor, attrs \\ %{}) do
    sponsor
    |> cast(attrs, ~w(name description website github_handle twitter_handle))
    |> validate_required([:name])
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> unique_constraint(:name)
  end

  def update_changeset(sponsor, attrs \\ %{}) do
    sponsor
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def sponsorship_count(sponsor) do
    Repo.count(from(e in EpisodeSponsor, where: e.sponsor_id == ^sponsor.id))
  end
end
