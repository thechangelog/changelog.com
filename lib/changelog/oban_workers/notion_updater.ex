defmodule Changelog.ObanWorkers.NotionUpdater do
  use Oban.Worker, queue: :scheduled

  require Logger

  alias Changelog.{Episode, Notion, Repo}

  @impl Oban.Worker
  def perform(_job) do
    reach()
  end

  def reach do
    for db <- ~w(b74d24c3ec414482a89af8df9955e702 c93a66e12ab14d41bc6b07b3c7e607d1) do
      reach(db)
    end
  end

  def reach(db) do
    db |> Notion.get_shipped_sponsorships() |> update_reach()
  end

  defp update_reach(sponsorships) when is_list(sponsorships) do
    for sponsorship <- sponsorships do
      update_reach(sponsorship)
    end
  end

  defp update_reach(sponsorship) when is_map(sponsorship) do
    id = get_in(sponsorship, ["id"])
    reach = get_in(sponsorship, ["properties", "Reach", "number"]) || 0
    url = get_in(sponsorship, ["properties", "URL", "url"])
    episode = episode_from_url(url)

    if episode do
      new_reach = round(episode.download_count)

      if new_reach > reach do
        Logger.info("Updating reach for #{url} to #{new_reach}")
        Notion.update_page(id, %{Reach: new_reach})
      end
    end
  end

  defp episode_from_url(nil), do: nil
  defp episode_from_url(url) do
    try do
      uri = URI.parse(url)
      [_, p_slug, e_slug] = String.split(uri.path, "/")

      Episode.published()
      |> Episode.with_podcast_slug(p_slug)
      |> Episode.with_slug(e_slug)
      |> Episode.limit(1)
      |> Repo.one()
    rescue
      _ -> nil
    end
  end
end
