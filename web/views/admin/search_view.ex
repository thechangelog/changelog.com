defmodule Changelog.Admin.SearchView do
  use Changelog.Web, :view

  def render("index.json", %{people: people}) do
    %{results: render_many(people, __MODULE__, "person.json", as: :person)}
  end

  def render("index.json", %{sponsors: sponsors}) do
    %{results: render_many(sponsors, __MODULE__, "sponsor.json", as: :sponsor)}
  end

  def render("index.json", %{channels: channels}) do
    %{results: render_many(channels, __MODULE__, "channel.json", as: :channel)}
  end

  def render("person.json", %{person: person}) do
    %{id: person.id,
      title: person.name,
      description: "(@#{person.handle})",
      image: avatar_url(person)}
  end

  def render("sponsor.json", %{sponsor: sponsor}) do
    latest =
      sponsor
      |> Ecto.assoc(:episode_sponsors)
      |> Changelog.EpisodeSponsor.newest_first
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
      image: Changelog.SponsorView.logo_image_url(sponsor, :small),
      extras: extras}
  end

  def render("channel.json", %{channel: channel}) do
    %{id: channel.id,
      title: channel.name,
      slug: channel.slug}
  end
end
