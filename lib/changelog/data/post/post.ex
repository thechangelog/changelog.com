defmodule Changelog.Post do
  use Changelog.Data, default_sort: :published_at

  alias Changelog.{Person, PostTopic, Regexp}

  schema "posts" do
    field :title, :string

    field :slug, :string
    field :guid, :string

    field :tldr, :string
    field :body, :string

    field :published, :boolean, default: false
    field :published_at, Timex.Ecto.DateTime

    belongs_to :author, Person
    has_many :post_topics, PostTopic, on_delete: :delete_all
    has_many :topics, through: [:post_topics, :topic]

    timestamps()
  end

  def admin_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(title slug author_id published published_at body tldr))
    |> validate_required([:title, :slug, :author_id])
    |> validate_format(:slug, Regexp.slug, message: Regexp.slug_message)
    |> unique_constraint(:slug)
    |> validate_published_has_published_at
    |> cast_assoc(:post_topics)
  end

  def published(query \\ __MODULE__),    do: from(q in query, where: q.published == true, where: q.published_at <= ^Timex.now)
  def scheduled(query \\ __MODULE__),    do: from(q in query, where: q.published == true, where: q.published_at > ^Timex.now)
  def search(query \\ __MODULE__, term), do: from(q in query, where: fragment("search_vector @@ plainto_tsquery('english', ?)", ^term))
  def unpublished(query \\ __MODULE__),  do: from(q in query, where: q.published == false)

  def is_public(post, as_of \\ Timex.now) do
    post.published && post.published_at <= as_of
  end

  def preload_all(post), do: post |> preload_author |> preload_topics

  def preload_author(post), do: Repo.preload(post, :author)

  def preload_topics(post) do
    post
    |> Repo.preload(post_topics: {PostTopic.by_position, :topic})
    |> Repo.preload(:topics)
  end

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
