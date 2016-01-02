defmodule Changelog.Admin.SearchView do
  use Changelog.Web, :view

  def render("index.json", %{people: people}) do
    %{results: render_many(people, __MODULE__, "person.json", as: :person)}
  end

  def render("person.json", %{person: person}) do
    %{
      id: person.id,
      title: person.name,
      description: "(@#{person.handle})",
      image: Changelog.Admin.PersonView.avatar_url(person)
    }
  end
end
