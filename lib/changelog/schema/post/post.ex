defmodule Changelog.Post do
  use Changelog.Schema, default_sort: :published_at

  alias Changelog.{NewsItem, Person, PostTopic, Regexp}

  schema "posts" do
    field :title, :string

    field :slug, :string
    field :guid, :string
    field :canonical_url, :string

    field :tldr, :string
    field :body, :string

    field :published, :boolean, default: false
    field :published_at, :utc_datetime

    belongs_to :author, Person
    has_many :post_topics, PostTopic, on_delete: :delete_all
    has_many :topics, through: [:post_topics, :topic]

    timestamps()
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(title slug canonical_url author_id published published_at body tldr)a)
    |> validate_required([:title, :slug, :author_id])
    |> validate_format(:canonical_url, Regexp.http(), message: Regexp.http_message())
    |> validate_format(:slug, Regexp.slug(), message: Regexp.slug_message())
    |> unique_constraint(:slug)
    |> validate_published_has_published_at()
    |> cast_assoc(:post_topics)
  end

  def authored_by(query \\ __MODULE__, person), do: from(q in query, where: q.author_id == ^person.id)
  def published(query \\ __MODULE__),           do: from(q in query, where: q.published, where: q.published_at <= ^Timex.now)
  def scheduled(query \\ __MODULE__),           do: from(q in query, where: q.published, where: q.published_at > ^Timex.now)
  def search(query \\ __MODULE__, term),        do: from(q in query, where: fragment("search_vector @@ plainto_tsquery('english', ?)", ^term))
  def unpublished(query \\ __MODULE__),         do: from(q in query, where: not(q.published))

  def is_public(post, as_of \\ Timex.now) do
    post.published && Timex.before?(post.published_at, as_of)
  end

  def is_published(post), do: post.published

  def is_publishable(post) do
    validated =
      post
      |> admin_changeset(%{})
      |> validate_required([:slug, :title, :published_at, :tldr, :body])

    validated.valid? && !is_published(post)
  end

  def preload_all(post) do
    post
    |> preload_author()
    |> preload_topics()
  end

  def preload_author(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :author)
  def preload_author(post), do: Repo.preload(post, :author)

  def preload_topics(query = %Ecto.Query{}) do
    query
    |> Ecto.Query.preload(post_topics: ^PostTopic.by_position)
    |> Ecto.Query.preload(:topics)
  end
  def preload_topics(post) do
    post
    |> Repo.preload(post_topics: {PostTopic.by_position, :topic})
    |> Repo.preload(:topics)
  end

  def get_news_item(post) do
    post
    |> NewsItem.with_post()
    |> Repo.one()
  end

  def load_news_item(post) do
    item = post |> get_news_item() |> NewsItem.load_object(post)
    Map.put(post, :news_item, item)
  end

  def object_id(post), do: "posts:#{post.slug}"

  defp validate_published_has_published_at(changeset) do
    published = get_field(changeset, :published)
    published_at = get_field(changeset, :published_at)

    if published && is_nil(published_at) do
      add_error(changeset, :published_at, "can't be blank when published")
    else
      changeset
    end
  end
end
