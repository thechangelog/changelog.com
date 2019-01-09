defmodule ChangelogWeb.PersonView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, Person, Podcast}
  alias ChangelogWeb.{Endpoint, SharedView, PodcastView}

  def avatar_path(person, version) do
    {person.avatar, person}
    |> Files.Avatar.url(version)
    |> String.replace_leading("/priv", "")
  end

  def avatar_url(person), do: avatar_url(person, :small)
  def avatar_url(person, version) do
    if person.avatar do
      static_url(Endpoint, avatar_path(person, version))
    else
      gravatar_url(person.email, version)
    end
  end

  defp gravatar_url(email, version) do
    size = case version do
      :small  -> 150
      :medium -> 300
      :large  -> 600
      _else   -> 100
    end

    hash = email
      |> String.trim
      |> String.downcase
      |> :erlang.md5
      |> Base.encode16(case: :lower)

    "https://secure.gravatar.com/avatar/#{hash}.jpg?s=#{size}&d=mm"
  end

  @spec comma_separated_names([binary()]) :: binary()
  def comma_separated_names(people)
  def comma_separated_names([first]),                do: first.name
  def comma_separated_names([first, second]),        do: "#{first.name} and #{second.name}"
  def comma_separated_names([first, second, third]), do: "#{first.name}, #{second.name}, and #{third.name}"
  def comma_separated_names([first | rest]),         do: "#{first.name}, #{comma_separated_names(rest)}"
  def comma_separated_names(_unhandled),             do: ""

  def external_url(person) do
    cond do
      person.website -> person.website
      person.twitter_handle -> twitter_url(person.twitter_handle)
      person.github_handle -> github_url(person.github_handle)
      true -> "#"
    end
  end

  def first_name(person) do
    person.name
    |> String.split(" ")
    |> List.first()
  end

  def handle(person), do: person.handle

  def is_profile_complete(person) do
    !!(person.bio && person.website && person.location)
  end

  def is_subscribed(person, newsletter) do
    case Craisin.Subscriber.details(newsletter.list_id, person.email) do
      %{"State" => "Active"} -> true
      _else -> false
    end
  end

  def is_staff(person), do: String.match?(person.email, ~r/@changelog.com/)

  def list_of_links(person) do
    [%{value: person.twitter_handle, text: "Twitter", url: twitter_url(person.twitter_handle)},
     %{value: person.github_handle, text: "GitHub", url: github_url(person.github_handle)},
     %{value: person.website, text: "Website", url: person.website}]
    |> Enum.reject(fn(x) -> x.value == nil end)
    |> Enum.map(fn(x) -> ~s{<a href="#{x.url}">#{x.text}</a>} end)
    |> Enum.join(", ")
  end

  def opt_out_path(conn, person, notification) do
    {:ok, encoded} = Person.encoded_id(person)
    home_path(conn, :opt_out, encoded, notification)
  end

  def opt_out_url(conn, person, notification) do
    {:ok, encoded} = Person.encoded_id(person)
    home_url(conn, :opt_out, encoded, notification)
  end
end
