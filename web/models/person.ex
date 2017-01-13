defmodule Changelog.Person do
  use Changelog.Web, :model
  use Arc.Ecto.Schema

  alias Changelog.Regexp

  schema "people" do
    field :name, :string
    field :email, :string
    field :handle, :string
    field :github_handle, :string
    field :twitter_handle, :string
    field :website, :string
    field :bio, :string
    field :auth_token, :string
    field :auth_token_expires_at, Timex.Ecto.DateTime
    field :signed_in_at, Timex.Ecto.DateTime
    field :admin, :boolean
    field :avatar, Changelog.Avatar.Type

    has_many :podcast_hosts, Changelog.PodcastHost, on_delete: :delete_all
    has_many :episode_hosts, Changelog.EpisodeHost, on_delete: :delete_all
    has_many :episode_guests, Changelog.EpisodeGuest, on_delete: :delete_all

    timestamps()
  end

  @required_fields ~w(name email handle)
  @optional_fields ~w(github_handle twitter_handle bio website admin)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, ~w(avatar))
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> validate_format(:handle, Regexp.slug, message: Regexp.slug_message)
    |> validate_length(:handle, max: 40, message: "max 40 chars")
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> unique_constraint(:handle)
  end

  def auth_changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(auth_token auth_token_expires_at), [])
  end

  def sign_in_changes(model) do
    change(model, %{
      auth_token: nil,
      auth_token_expires_at: nil,
      signed_in_at: Timex.now
    })
  end

  def encoded_auth(model) do
    {:ok, Base.encode16("#{model.email}|#{model.auth_token}")}
  end

  def decoded_auth(encoded) do
    {:ok, decoded} = Base.decode16(encoded)
    String.split(decoded, "|")
  end

  def episode_count(person) do
    host_count = Repo.one from(e in Changelog.EpisodeHost,
      where: e.person_id == ^person.id,
      select: count(e.id))

    guest_count = Repo.one from(e in Changelog.EpisodeGuest,
      where: e.person_id == ^person.id,
      select: count(e.id))

    host_count + guest_count
  end

  def post_count(person) do
    Repo.one from(p in Changelog.Post,
      where: p.author_id == ^person.id,
      select: count(p.id))
  end
end
