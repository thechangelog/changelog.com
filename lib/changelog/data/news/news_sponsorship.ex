defmodule Changelog.NewsSponsorship do
  use Changelog.Data

  alias Changelog.Sponsor

  schema "news_sponsorships" do
    field :name, :string
    field :weeks, {:array, :date}, default: nil
    field :impression_count, :integer, default: 0
    field :click_count, :integer, default: 0

    belongs_to :sponsor, Sponsor
    timestamps()
  end

  def admin_changeset(sponsorship, attrs \\ %{}) do
    sponsorship
    |> cast(attrs, ~w(name weeks sponsor_id))
    |> validate_required([:weeks, :sponsor_id])
    |> validate_length(:weeks, min: 1)
    |> foreign_key_constraint(:sponsor_id)
  end

  def preload_sponsor(query = %Ecto.Query{}), do: Ecto.Query.preload(query, :sponsor)
  def preload_sponsor(sponsorship), do: Repo.preload(sponsorship, :sponsor)

  def week_of(date), do: from(s in __MODULE__, where: ^date in s.weeks)
end
