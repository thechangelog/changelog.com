defmodule ChangelogWeb.PersonView do
  use ChangelogWeb, :public_view

  alias Changelog.{Files, HtmlKit, NewsItem, Person, Podcast}
  alias ChangelogWeb.{EpisodeView, SharedView, PodcastView}

  def avatar_url(person), do: avatar_url(person, :small)

  def avatar_url(person, version) do
    if person.avatar do
      Files.Avatar.url({person.avatar, person}, version)
    else
      gravatar_url(person.email, version)
    end
  end

  def bio_as_html(person) do
    person.bio
    |> SharedHelpers.md_to_safe_html()
    |> HtmlKit.put_ugc()
  end

  defp gravatar_url(email, version) do
    size =
      case version do
        :thumb -> 50
        :small -> 150
        :medium -> 300
        :large -> 600
        _else -> 100
      end

    hash =
      email
      |> String.trim()
      |> String.downcase()
      |> :erlang.md5()
      |> Base.encode16(case: :lower)

    "https://secure.gravatar.com/avatar/#{hash}.jpg?s=#{size}&d=mm"
  end

  def external_url(person) do
    cond do
      person.website -> person.website
      person.twitter_handle -> SharedHelpers.twitter_url(person.twitter_handle)
      person.github_handle -> SharedHelpers.github_url(person.github_handle)
      person.linkedin_handle -> SharedHelpers.linkedin_url(person.linkedin_handle)
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

  def is_subscribed(_person, nil), do: false

  def is_subscribed(person, %NewsItem{id: id}) do
    person
    |> Person.preload_subscriptions()
    |> Map.get(:subscriptions)
    |> Enum.any?(&(&1.item_id == id))
  end

  def is_subscribed(person, %Podcast{id: id}) do
    person
    |> Person.preload_subscriptions()
    |> Map.get(:subscriptions)
    |> Enum.any?(&(&1.podcast_id == id))
  end

  def is_subscribed(person, newsletter) do
    Craisin.Subscriber.is_subscribed(newsletter.id, person.email)
  end

  def is_staff(person), do: String.match?(person.email, ~r/@changelog.com/)

  def list_of_links(person, separator \\ ", ") do
    [
      %{value: person.website, text: "Website", url: person.website},
      %{
        value: person.github_handle,
        text: "GitHub",
        url: SharedHelpers.github_url(person.github_handle)
      },
      %{
        value: person.linkedin_handle,
        text: "LinkedIn",
        url: SharedHelpers.linkedin_url(person.linkedin_handle)
      },
      %{
        value: person.bsky_handle,
        text: "Bluesky",
        url: SharedHelpers.bsky_url(person.bsky_handle)
      },
      %{
        value: person.mastodon_handle,
        text: "Mastodon",
        url: SharedHelpers.mastodon_url(person.mastodon_handle)
      },
      %{
        value: person.twitter_handle,
        text: "X",
        url: SharedHelpers.x_url(person.twitter_handle)
      }
    ]
    |> Enum.reject(fn x -> x.value == nil end)
    |> Enum.map(fn x -> ~s{<a href="#{x.url}" rel="external ugc">#{x.text}</a>} end)
    |> Enum.join(separator)
  end

  def opt_out_path(person, type, id) do
    {:ok, encoded} = Person.encoded_id(person)
    ~p"/~/nope/#{encoded}/#{type}/#{id}"
  end

  def opt_out_url(person, type, id) do
    {:ok, encoded} = Person.encoded_id(person)
    url(~p"/~/nope/#{encoded}/#{type}/#{id}")
  end

  def profile_path(person = %{public_profile: true}) do
    ~p"/person/#{person.handle}"
  end

  def profile_path(person), do: external_url(person)

  def profile_url(person = %{public_profile: true}) do
    url(~p"/person/#{person.handle}")
  end

  def profile_url(person), do: external_url(person)
end
