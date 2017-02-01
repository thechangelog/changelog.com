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
    field :slack_id, :string
    field :website, :string
    field :bio, :string
    field :location, :string
    field :auth_token, :string
    field :auth_token_expires_at, Timex.Ecto.DateTime
    field :joined_at, Timex.Ecto.DateTime
    field :signed_in_at, Timex.Ecto.DateTime
    field :admin, :boolean
    field :avatar, Changelog.Avatar.Type

    has_many :podcast_hosts, Changelog.PodcastHost, on_delete: :delete_all
    has_many :episode_hosts, Changelog.EpisodeHost, on_delete: :delete_all
    has_many :episode_guests, Changelog.EpisodeGuest, on_delete: :delete_all

    timestamps()
  end

  def get_by_ueberauth(%{provider: :twitter, info: %{nickname: handle}}) do
    Repo.get_by(__MODULE__, twitter_handle: handle)
  end
  def get_by_ueberauth(%{provider: :github, info: %{nickname: handle}}) do
    Repo.get_by(__MODULE__, github_handle: handle)
  end
  def get_by_ueberauth(_), do: nil

  def auth_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(auth_token auth_token_expires_at))
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name email handle github_handle twitter_handle bio website location admin))
    |> shared_changeset
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name email handle github_handle twitter_handle bio location website))
    |> shared_changeset
  end

  defp shared_changeset(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, ~w(avatar))
    |> validate_required([:name, :email, :handle])
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> validate_format(:handle, Regexp.slug, message: Regexp.slug_message)
    |> validate_length(:handle, max: 40, message: "max 40 chars")
    |> unique_constraint(:name)
    |> unique_constraint(:email)
    |> unique_constraint(:handle)
    |> unique_constraint(:github_handle)
    |> unique_constraint(:twitter_handle)
  end

  def sign_in_changeset(person) do
    change(person, %{
      auth_token: nil,
      auth_token_expires_at: nil,
      signed_in_at: Timex.now,
      joined_at: (person.joined_at || Timex.now)
    })
  end

  def slack_changeset(person, slack_id) do
    change(person, %{slack_id: slack_id})
  end

  def refresh_auth_token(person, expires_in \\ 15) do
    auth_token = Base.encode16(:crypto.strong_rand_bytes(8))
    expires_at = Timex.add(Timex.now, Timex.Duration.from_minutes(expires_in))
    changeset = auth_changeset(person, %{auth_token: auth_token, auth_token_expires_at: expires_at})
    {:ok, person} = Repo.update(changeset)
    person
  end

  def encoded_auth(person) do
    {:ok, Base.encode16("#{person.email}|#{person.auth_token}")}
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
