defmodule Changelog.NewsSponsorship do
  use Changelog.Data

  alias Changelog.{NewsAd, Sponsor}

  schema "news_sponsorships" do
    field :name, :string
    field :weeks, {:array, :date}, default: nil
    field :impression_count, :integer, default: 0
    field :click_count, :integer, default: 0

    belongs_to :sponsor, Sponsor
    has_many :ads, NewsAd, foreign_key: :sponsorship_id, on_delete: :delete_all

    timestamps()
  end

  def week_of(date) do
    date = Timex.beginning_of_week(date)
    from(s in __MODULE__, where: ^date in s.weeks)
  end

  def admin_changeset(sponsorship, attrs \\ %{}) do
    sponsorship
    |> cast(attrs, ~w(name weeks sponsor_id))
    |> validate_required([:weeks, :sponsor_id])
    |> validate_length(:weeks, min: 1)
    |> foreign_key_constraint(:sponsor_id)
    |> cast_assoc(:ads)
  end

  def preload_all(sponsorship) do
    sponsorship
    |> preload_ads
    |> preload_sponsor
  end

  def preload_ads(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :ads)
  def preload_ads(sponsorship), do: Repo.preload(sponsorship, :ads)

  def preload_sponsor(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :sponsor)
  def preload_sponsor(sponsorship), do: Repo.preload(sponsorship, :sponsor)

  def ad_for_issue(sponsorship), do: select_ad(preload_ads(sponsorship).ads)
  defp select_ad([]), do: nil
  defp select_ad(ads) do
    Enum.find(ads, fn(x) -> x.newsletter end) ||
    Enum.find(ads, fn(x) -> NewsAd.has_no_issues(x) end) ||
    Enum.random(ads)
  end
end
