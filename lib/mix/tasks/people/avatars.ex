defmodule Mix.Tasks.Changelog.Avatars do
  use Mix.Task

  alias Changelog.{Episode, Person, Podcast, Repo}
  alias ChangelogWeb.{PersonView}

  @shortdoc "Downloads all people's avatars to a temp directory"

  def run(_) do
    Mix.Task.run "app.start"

    File.mkdir("avatars")

    for person <- all_people_on_podcast("practicalai") do
      try do
        url = PersonView.avatar_url(person)

        url = if String.starts_with?(url, "http") do
          url
        else
          "https://cdn.changelog.com#{url}"
        end

        %HTTPoison.Response{body: body} = HTTPoison.get!(url)
        hash = :crypto.hash(:md5, body) |> Base.encode16(case: :lower)

        # this is the default gravatar's md5
        if hash != "2899242106ef16dbcfdec0ac41865ff8" do
          File.write("avatars/#{person.handle}.png", body)
        end
      rescue
        e -> IO.puts "Failed to download #{person.name}. #{e}"
      end
    end
  end

  # defp all_people, do: Repo.all(Person)

  defp all_people_on_podcast(slug) do
    Podcast
    |> Repo.get_by(slug: slug)
    |> Ecto.assoc(:episodes)
    |> Episode.published()
    |> Repo.all()
    |> Enum.map(&Episode.participants/1)
    |> List.flatten()
    |> Enum.uniq()
  end
end
