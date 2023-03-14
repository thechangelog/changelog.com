defmodule Changelog.Newsletters do
  alias Changelog.Cache

  defmodule Newsletter do
    defstruct name: nil, slug: nil, description: "", id: nil, web_id: nil, stats: %{}
  end

  def all, do: [weekly(), nightly()]

  def slugs, do: Enum.map(all(), & &1.slug)

  def get_by_slug(slug) do
    Enum.find(all(), fn newsletter -> newsletter.slug == slug end)
  end

  def nightly do
    %Newsletter{
      name: "Changelog Nightly",
      slug: "nightly",
      description:
        "Our automated nightly email powered by GH Archive that unearths the hottest new repos trending on GitHub before they blow up.",
      id: "95a8fbc221a2240ac7469d661bac650a",
      web_id: "82E49C221D20C4F7"
    }
  end

  def weekly do
    %Newsletter{
      name: "Changelog Weekly",
      slug: "weekly",
      description:
        "Our editorialized take covering this week in dev culture, software development, open source, building startups, creative work, and the people involved.",
      id: "eddd53c07cf9e23029fe8a67fe84731f",
      web_id: "82E49C221D20C4F7"
    }
  end

  def get_stats(newsletter) do
    cache_key = "newsletter_#{newsletter.id}_stats"

    stats =
      Cache.get_or_store(cache_key, :timer.hours(1), fn ->
        Craisin.List.stats(newsletter.id)
      end)

    %Newsletter{newsletter | stats: stats}
  end
end
