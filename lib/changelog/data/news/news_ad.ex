defmodule Changelog.NewsAd do
  use Changelog.Data

  alias Changelog.{Files, NewsSponsorship, Regexp}

  schema "news_ads" do
    field :url, :string
    field :headline, :string
    field :story, :string
    field :image, Files.Image.Type

    field :active, :boolean, default: true
    field :newsletter, :boolean, default: false

    field :impression_count, :integer, default: 0
    field :click_count, :integer, default: 0

    field :delete, :boolean, virtual: true

    belongs_to :sponsorship, NewsSponsorship

    timestamps()
  end

  def changeset(ad, attrs \\ %{}) do
    ad
    |> cast(attrs, ~w(url headline story active newsletter delete))
    |> cast_attachments(attrs, ~w(image))
    |> validate_required([:url, :headline])
    |> validate_format(:url, Regexp.http, message: Regexp.http_message)
    |> foreign_key_constraint(:sponsorship_id)
    |> mark_for_deletion()
  end

  defp mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
