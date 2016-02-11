defmodule Changelog.Person do
  use Changelog.Web, :model

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

    has_many :podcast_hosts, Changelog.PodcastHost, on_delete: :delete_all
    has_many :episode_hosts, Changelog.EpisodeHost, on_delete: :delete_all
    has_many :episode_guests, Changelog.EpisodeGuest, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(name email handle)
  @optional_fields ~w(github_handle twitter_handle bio website admin)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> validate_format(:handle, Regexp.slug, message: Regexp.slug_message)
    |> validate_length(:handle, max: 40, message: "max 40 chars")
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> unique_constraint(:handle)
  end

  def auth_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(auth_token auth_token_expires_at), [])
  end

  def sign_in_changes(model) do
    change(model, %{
      auth_token: nil,
      auth_token_expires_at: nil,
      signed_in_at: Timex.Date.now
    })
  end

  def encoded_auth(model) do
    {:ok, Base.encode16("#{model.email}|#{model.auth_token}")}
  end

  def decoded_auth(encoded) do
    {:ok, decoded} = Base.decode16(encoded)
    String.split(decoded, "|")
  end
end
