defmodule Changelog.Benefit do
  use Changelog.Web, :model

  schema "benefits" do
    field :offer, :string
    field :code, :string
    field :link_url, :string
    field :notes, :string

    belongs_to :sponsor, Changelog.Sponsor

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(offer notes code link_url sponsor_id))
    |> validate_required([:offer, :sponsor_id])
  end
end
