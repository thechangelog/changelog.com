defmodule Changelog.Benefit do
  use Changelog.Data

  alias Changelog.{Sponsor}

  schema "benefits" do
    field :offer, :string
    field :code, :string
    field :link_url, :string
    field :notes, :string

    belongs_to :sponsor, Sponsor

    timestamps()
  end

  def admin_changeset(benefit, attrs \\ %{}) do
    benefit
    |> cast(attrs, ~w(offer notes code link_url sponsor_id)a)
    |> validate_required([:offer, :sponsor_id])
  end

  def preload_all(benefit) do
    benefit
    |> preload_sponsor
  end

  def preload_sponsor(benefit) do
    Repo.preload(benefit, :sponsor)
  end
end
