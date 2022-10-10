defmodule Changelog.EpisodeChapter do
  use Changelog.Schema

  alias Changelog.Regexp

  embedded_schema do
    field :title, :string
    field :starts_at, :float
    field :ends_at, :float
    field :link_url, :string
    field :image_url, :string

    field :delete, :boolean, virtual: true
  end

  def changeset(chapter, attrs \\ %{}) do
    chapter
    |> cast(attrs, ~w(title starts_at ends_at link_url image_url delete)a)
    |> validate_required([:title, :starts_at])
    |> validate_format(:link_url, Regexp.http(), message: Regexp.http_message())
    |> validate_format(:image_url, Regexp.http(), message: Regexp.http_message())
    |> validate_ends_at_after_starts_at()
    |> mark_for_deletion()
  end

  defp validate_ends_at_after_starts_at(changeset) do
    starts_at = get_field(changeset, :starts_at)
    ends_at = get_field(changeset, :ends_at)

    cond do
      !is_nil(ends_at) && is_nil(starts_at) -> add_error(changeset, :ends_at, "cannot be set without 'starts at'")
      !is_nil(ends_at) && starts_at >= ends_at -> add_error(changeset, :ends_at, "must be later than 'starts at'")
      true -> changeset
    end
  end
end
