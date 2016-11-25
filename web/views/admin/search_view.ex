defmodule Changelog.Admin.SearchView do
  use Changelog.Web, :view

  alias Changelog.Endpoint

  @limit 3

  def render("all.json", _params = %{results: results, query: query}) do
    response = %{results: %{
      channels: %{name: "Channels", results: process_results(results.channels, &channel_result/1)},
      episodes: %{name: "Episodes", results: process_results(results.episodes, &episode_result/1)},
      people: %{name: "People", results: process_results(results.people, &person_result/1)},
      posts: %{name: "Posts", results: process_results(results.posts, &post_result/1)},
      sponsors: %{name: "Sponsors", results: process_results(results.sponsors, &sponsor_result/1)}}}

    counts = Enum.map(results, fn({_type, results}) -> Enum.count(results) end)
    if Enum.any?(counts, fn(count) -> count > @limit end) do
      response
      |> Map.put(:action, %{url: "/admin/search?q=#{query}", text: "View all #{Enum.sum(counts)} results"})
    else
      response
    end
  end

  def render("channel.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &channel_result/1)}
  end

  def render("person.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &person_result/1)}
  end

  def render("sponsor.json", _params = %{results: results, query: _query}) do
    %{results: Enum.map(results, &sponsor_result/1)}
  end

  defp process_results(records, processFn) do
    records
    |> Enum.take(@limit)
    |> Enum.map(processFn)
  end

  defp channel_result(channel) do
    %{id: channel.id,
      title: channel.name,
      slug: channel.slug,
      url: admin_channel_path(Endpoint, :edit, channel)}
  end

  defp episode_result(episode) do
    %{id: episode.id,
      title: Changelog.EpisodeView.numbered_title(episode),
      url: admin_podcast_episode_path(Endpoint, :show, episode.podcast.slug, episode.slug)}
  end

  defp person_result(person) do
    %{id: person.id,
      title: person.name,
      description: "(@#{person.handle})",
      image: Changelog.PersonView.avatar_url(person),
      url: admin_person_path(Endpoint, :edit, person)}
  end

  defp post_result(post) do
    %{title: post.title, url: admin_post_path(Endpoint, :edit, post)}
  end

  defp sponsor_result(sponsor) do
    latest =
      sponsor
      |> Ecto.assoc(:episode_sponsors)
      |> Changelog.EpisodeSponsor.newest_first
      |> Ecto.Query.first
      |> Changelog.Repo.one

    extras = if latest do
       %{title: latest.title,
         link_url: latest.link_url,
         description: latest.description}
    else
      %{title: sponsor.name,
        link_url: sponsor.website,
        description: sponsor.description}
    end

    %{id: sponsor.id,
      title: sponsor.name,
      description: sponsor.description,
      image: Changelog.SponsorView.logo_url(sponsor, :color_logo, :small),
      url: admin_sponsor_path(Endpoint, :edit, sponsor),
      extras: extras}
  end
end
