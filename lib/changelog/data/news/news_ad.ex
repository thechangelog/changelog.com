defmodule Changelog.NewsAd do
  use Changelog.Data

  alias Changelog.{Files, NewsIssueAd, NewsSponsorship, Regexp}

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
    has_many :news_issue_ads, NewsIssueAd, foreign_key: :ad_id, on_delete: :delete_all
    has_many :issues, through: [:news_issue_ads, :issue]

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

  def preload_issues(ad) do
    ad
    |> Repo.preload(news_issue_ads: {NewsIssueAd.by_position, :issue})
    |> Repo.preload(:issues)
  end

  def has_no_issues(ad), do: preload_issues(ad).issues |> Enum.empty?

  defp mark_for_deletion(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
