defmodule Changelog.Metacast do
  use Changelog.Schema

  alias Changelog.EpisodeTracker
  alias Changelog.Files
  alias Changelog.Metacasts.Filterer
  alias Changelog.Metacasts.Filterer.Cache

  schema "metacasts" do
    field :name, :string
    field :description, :string
    field :keywords, :string
    field :slug, :string
    field :is_official, :boolean, default: false

    field :cover, Files.Cover.Type
    field :filter_query, :string

    timestamps()
  end

  @minimal_filter_query "except"

  def file_changeset(metacast, attrs \\ %{}), do: cast_attachments(metacast, attrs, [:cover])

  def insert_changeset(metacast, attrs \\ %{}) do
    metacast
    |> cast(attrs, ~w(name description keywords slug is_official filter_query)a)
    |> ensure_minimal_filter_query()
    |> validate_required([:name, :slug, :is_official, :filter_query])
    |> validate_filter_query()
  end

  def update_changeset(metacast, attrs \\ %{}) do
    metacast
    |> insert_changeset(attrs)
    |> file_changeset(attrs)
  end

  def get_by_slug!(slug) do
    Repo.get_by!(__MODULE__, slug: slug)
  end

  def get_episode_ids!(metacast) do
    {:ok, episodes} = EpisodeTracker.get_episodes_as_ids(metacast.filter_query)
    episodes
  end

  defp ensure_minimal_filter_query(changeset = %{changes: %{filter_query: nil}}) do
    change(changeset, filter_query: @minimal_filter_query)
  end

  defp ensure_minimal_filter_query(changeset = %{changes: %{filter_query: ""}}) do
    change(changeset, filter_query: @minimal_filter_query)
  end

  defp ensure_minimal_filter_query(changeset), do: changeset

  defp validate_filter_query(changeset = %{changes: %{filter_query: filter_query}}) do
    case Cache.compile(filter_query) do
      {:ok, _} ->
        changeset

      {:error, :no_start} ->
        add_error(
          changeset,
          :filter_query,
          "Your filter doesn't have a start statement. Start is either 'only' or 'except'."
        )

      {:error, :too_many_statements} ->
        add_error(
          changeset,
          :filter_query,
          "Your filter has too many statements. Statement limit: #{Filterer.statement_limit()}"
        )

      {:error, error} ->
        add_error(changeset, :filter_query, "Error in filter parsing: #{error}")
    end
  end

  defp validate_filter_query(changeset), do: changeset
end
