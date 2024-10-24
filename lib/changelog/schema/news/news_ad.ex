defmodule Changelog.NewsAd do
  use Changelog.Schema

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
    has_many :news_issue_ads, NewsIssueAd, foreign_key: :ad_id
    has_many :issues, through: [:news_issue_ads, :issue]

    timestamps()
  end

  def with_image(query \\ __MODULE__), do: from(q in query, where: not is_nil(q.image))

  def changeset(ad, attrs \\ %{}) do
    ad
    |> cast(attrs, [:url, :headline, :story, :active, :newsletter, :delete])
    |> cast_attachments(attrs, [:image])
    |> validate_required([:url, :headline])
    |> validate_format(:url, Regexp.http(), message: Regexp.http_message())
    |> foreign_key_constraint(:sponsorship_id)
    |> mark_for_deletion()
  end

  def active_first(query \\ __MODULE__),
    do: from(q in query, order_by: [desc: :newsletter, desc: :active])

  def preload_all(ad) do
    ad
    |> preload_issues
    |> preload_sponsorship
  end

  def preload_issues(ad) do
    ad
    |> Repo.preload(news_issue_ads: {NewsIssueAd.by_position(), :issue})
    |> Repo.preload(:issues)
  end

  def preload_sponsorship(query = %Ecto.Query{}),
    do: Ecto.Query.preload(query, sponsorship: :sponsor)

  def preload_sponsorship(ad), do: Repo.preload(ad, sponsorship: :sponsor)

  def has_no_issues(ad), do: preload_issues(ad).issues |> Enum.empty?()

  def slug(ad) do
    ad.headline
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s]/, "")
    |> String.replace(~r/\s+/, "-")
    |> Kernel.<>("-#{hashid(ad)}")
  end

  def track_click(ad) do
    ad
    |> change(%{click_count: ad.click_count + 1})
    |> Repo.update!()

    ad.sponsorship
    |> change(%{click_count: ad.sponsorship.click_count + 1})
    |> Repo.update!()
  end

  def track_impression(ad) do
    ad
    |> change(%{impression_count: ad.impression_count + 1})
    |> Repo.update!()

    ad.sponsorship
    |> change(%{impression_count: ad.sponsorship.impression_count + 1})
    |> Repo.update!()
  end
end
