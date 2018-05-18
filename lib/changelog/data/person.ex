defmodule Changelog.Person do
  use Changelog.Data

  alias Changelog.{EpisodeHost, EpisodeGuest, Faker, Files, NewsItem, PodcastHost,
                   Post, Regexp}
  alias Timex.Duration

  defmodule Settings do
    use Changelog.Data

    @primary_key false
    embedded_schema do
      field :email_on_authored_news, :boolean, default: true
      field :email_on_submitted_news, :boolean, default: true
    end

    def changeset(struct, attrs) do
      cast(struct, attrs, [:email_on_authored_news, :email_on_submitted_news])
    end
  end

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
    field :joined_at, Timex.Ecto.DateTime
    field :signed_in_at, Timex.Ecto.DateTime
    field :admin, :boolean
    field :avatar, Files.Avatar.Type

    embeds_one :settings, Settings, on_replace: :update

    has_many :podcast_hosts, PodcastHost, on_delete: :delete_all
    has_many :episode_hosts, EpisodeHost, on_delete: :delete_all
    has_many :episode_guests, EpisodeGuest, on_delete: :delete_all
    has_many :authored_posts, Post, foreign_key: :author_id, on_delete: :delete_all
    has_many :authored_news_items, NewsItem, foreign_key: :author_id
    has_many :logged_news_items, NewsItem, foreign_key: :logger_id

    timestamps()
  end

  def in_slack(query \\ __MODULE__), do: from(p in query, where: not(is_nil(p.slack_id)))
  def joined(query \\ __MODULE__), do: from(p in query, where: not(is_nil(p.joined_at)))

  def joined_today(query \\ __MODULE__) do
    today = Timex.subtract(Timex.now, Duration.from_days(1))
    from(p in query, where: p.joined_at > ^today)
  end

  def get_by_encoded_id(token) do
    [id, email] = __MODULE__.decoded_id(token)
    Repo.get_by(__MODULE__, id: id, email: email)
  end

  def get_by_ueberauth(%{provider: :twitter, info: %{nickname: handle}}) do
    Repo.get_by(__MODULE__, twitter_handle: handle)
  end
  def get_by_ueberauth(%{provider: :github, info: %{nickname: handle}}) do
    Repo.get_by(__MODULE__, github_handle: handle)
  end
  def get_by_ueberauth(_), do: nil

  def auth_changeset(person, attrs \\ %{}), do: cast(person, attrs, ~w(auth_token))

  def admin_insert_changeset(person, attrs \\ %{}) do
    allowed = ~w(name email handle github_handle twitter_handle bio website location admin)
    changeset_with_allowed_attrs(person, attrs, allowed)
  end

  def admin_update_changeset(person, attrs \\ %{}) do
    person
    |> admin_insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def file_changeset(person, attrs \\ %{}), do: cast_attachments(person, attrs, ~w(avatar), allow_urls: true)

  def insert_changeset(person, attrs \\ %{}) do
    allowed = ~w(name email handle github_handle twitter_handle bio website location)
    changeset_with_allowed_attrs(person, attrs, allowed)
  end

  def update_changeset(person, attrs \\ %{}) do
    person
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  defp changeset_with_allowed_attrs(person, attrs, allowed) do
    person
    |> cast(attrs, allowed)
    |> cast_embed(:settings)
    |> validate_required([:name, :email, :handle])
    |> validate_format(:email, Regexp.email)
    |> validate_format(:website, Regexp.http, message: Regexp.http_message)
    |> validate_format(:handle, Regexp.slug, message: Regexp.slug_message)
    |> validate_length(:handle, max: 40, message: "max 40 chars")
    |> unique_constraint(:email)
    |> unique_constraint(:handle)
    |> unique_constraint(:github_handle)
    |> unique_constraint(:twitter_handle)
  end

  def sign_in_changeset(person) do
    change(person, %{
      auth_token: nil,
      signed_in_at: Timex.now,
      joined_at: (person.joined_at || Timex.now)
    })
  end

  def slack_changeset(person, slack_id) do
    change(person, %{slack_id: slack_id})
  end

  def refresh_auth_token(person, auth_token) do
    changeset =
      Person.auth_changeset(person, %{
        auth_token: auth_token
      })

    {:ok, person} = Repo.update(changeset)
    person
  end

  def episode_count(person) do
    host_count = Repo.count(from(e in EpisodeHost, where: e.person_id == ^person.id))
    guest_count = Repo.count(from(e in EpisodeGuest, where: e.person_id == ^person.id))
    host_count + guest_count
  end

  def post_count(person) do
    Repo.count(from(p in Post, where: p.author_id == ^person.id))
  end

  def with_fake_data(person \\ %__MODULE__{}) do
    fake_name = Faker.name()
    fake_handle = Faker.handle(fake_name)
    %{person | name: fake_name, handle: fake_handle}
  end

  def sans_fake_data(person) do
    if Faker.name_fake?(person.name) do
     %{person | name: nil, handle: nil}
    else
      person
    end
  end
end
