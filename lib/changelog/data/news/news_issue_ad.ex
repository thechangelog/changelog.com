defmodule Changelog.NewsIssueAd do
  use Changelog.Data

  alias Changelog.{NewsIssue, NewsAd}

  schema "news_issue_ads" do
    field :position, :integer
    field :delete, :boolean, virtual: true

    belongs_to :ad, NewsAd, foreign_key: :ad_id
    belongs_to :issue, NewsIssue, foreign_key: :issue_id

    timestamps()
  end

  def changeset(issue_ad, params \\ %{}) do
    issue_ad
    |> cast(params, ~w(position ad_id issue_id delete)a)
    |> validate_required([:position])
    |> mark_for_deletion()
  end

  def build_and_preload({ad, position}) do
    %__MODULE__{position: position, ad_id: ad.id} |> Repo.preload(:ad)
  end
end
