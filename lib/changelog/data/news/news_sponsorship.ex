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

  def available_count(date), do: 4 - booked_count(date)
  def booked_count(date), do: date |> week_of() |> Repo.count()

  def admin_changeset(sponsorship, attrs \\ %{}) do
    sponsorship
    |> cast(attrs, ~w(name weeks sponsor_id)a)
    |> validate_required([:weeks, :sponsor_id])
    |> validate_length(:weeks, min: 1)
    |> validate_beginning_of_weeks
    |> foreign_key_constraint(:sponsor_id)
    |> cast_assoc(:ads)
  end

  def preload_all(sponsorship) do
    sponsorship
    |> preload_ads()
    |> preload_sponsor()
  end

  def preload_ads(query = %Ecto.Query{}), do: Ecto.Query.preload(query, ads: ^NewsAd.active_first)
  def preload_ads(sponsorship), do: Repo.preload(sponsorship, ads: NewsAd.active_first)

  def preload_sponsor(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :sponsor)
  def preload_sponsor(sponsorship), do: Repo.preload(sponsorship, :sponsor)

  def get_ads_for_index(count \\ 2) do
    Timex.today()
    |> week_of()
    |> preload_all()
    |> Repo.all()
    |> Enum.map(&ad_for_index/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.take_random(count)
  end

  def ad_for_index(sponsorship) do
    sponsorship
    |> preload_ads()
    |> Map.get(:ads, [])
    |> Enum.filter(&(&1.active))
    |> select_ad_for_index()
    |> ad_with_sponsorship_loaded(sponsorship)
    |> ad_with_sponsor_loaded(sponsorship)
  end

  def ad_for_issue(sponsorship) do
    sponsorship
    |> preload_ads()
    |> Map.get(:ads, [])
    |> Enum.filter(&(&1.active))
    |> select_ad_for_issue()
    |> ad_with_sponsor_loaded(sponsorship)
  end

  defp select_ad_for_index([]), do: nil
  defp select_ad_for_index(ads), do: Enum.random(ads)

  defp select_ad_for_issue([]), do: nil
  defp select_ad_for_issue(ads) do
    Enum.find(ads, fn(x) -> x.newsletter end) ||
    Enum.find(ads, fn(x) -> NewsAd.has_no_issues(x) end) ||
    Enum.random(ads)
  end

  defp ad_with_sponsorship_loaded(nil, _sponsorship), do: nil
  defp ad_with_sponsorship_loaded(ad, sponsorship), do: Map.put(ad, :sponsorship, sponsorship)

  defp ad_with_sponsor_loaded(nil, _sponsorship), do: nil
  defp ad_with_sponsor_loaded(ad, sponsorship), do: Map.put(ad, :sponsor, sponsorship.sponsor)

  defp validate_beginning_of_weeks(changeset) do
    weeks = get_field(changeset, :weeks) || []
    invalid = Enum.find(weeks, fn(week) -> Timex.beginning_of_week(week) != week end)

    if invalid do
      add_error(changeset, :weeks, "#{invalid} is not a Monday")
    else
      changeset
    end
  end
end
