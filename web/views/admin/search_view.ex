defmodule Changelog.Admin.SearchView do
  use Changelog.Web, :view

  def render("index.json", %{people: people}) do
    %{results: render_many(people, __MODULE__, "person.json", as: :person)}
  end

  def render("index.json", %{sponsors: sponsors}) do
    %{results: render_many(sponsors, __MODULE__, "sponsor.json", as: :sponsor)}
  end

  def render("index.json", %{topics: topics}) do
    %{results: render_many(topics, __MODULE__, "topic.json", as: :topic)}
  end

  def render("person.json", %{person: person}) do
    %{
      id: person.id,
      title: person.name,
      description: "(@#{person.handle})",
      image: avatar_url(person)
    }
  end

  def render("sponsor.json", %{sponsor: sponsor}) do
    %{
      id: sponsor.id,
      title: sponsor.name,
      description: sponsor.description,
      image: Changelog.SponsorView.logo_image_url(sponsor, :small),
      name: "HAIO"
    }
  end

  def render("topic.json", %{topic: topic}) do
    %{
      id: topic.id,
      title: topic.name,
      slug: topic.slug
    }
  end
end
