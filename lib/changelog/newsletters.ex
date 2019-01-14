defmodule Changelog.Newsletters do

  defmodule Newsletter do
    defstruct name: nil, list_id: nil, web_id: nil, stats: %{}
  end

  alias Changelog.Cache
  alias Changelog.Newsletters.Newsletter

  def all, do: [weekly(), nightly()]

  def get_by_slug(slug) do
    apply(__MODULE__, String.to_existing_atom(slug), [])
  end

  def nightly do
    %Newsletter{
      name: "Changelog Nightly",
      list_id: "95a8fbc221a2240ac7469d661bac650a",
      web_id: "82E49C221D20C4F7"
    }
  end

  def weekly do
    %Newsletter{
      name: "Changelog Weekly",
      list_id: "eddd53c07cf9e23029fe8a67fe84731f",
      web_id: "82E49C221D20C4F7"
    }
  end

  def get_stats(newsletter) do
    cache_key = "newsletter_#{newsletter.list_id}_stats"
    stats = Cache.get_or_store(cache_key, :timer.hours(1), fn ->
      Craisin.List.stats(newsletter.list_id)
    end)

    %Newsletter{newsletter | stats: stats}
  end
end
