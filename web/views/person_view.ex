defmodule Changelog.PersonView do
  use Changelog.Web, :view

  def avatar_url(person), do: avatar_url(person, :small)
  def avatar_url(person, version) do
    if person.avatar do
      Changelog.Avatar.url({person.avatar, person}, version)
      |> String.replace_leading("priv/static", "")
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
      |> String.strip
      |> String.downcase
      |> :erlang.md5
      |> Base.encode16(case: :lower)

    "https://secure.gravatar.com/avatar/#{hash}.jpg?s=#{size}&d=mm"
  end

  def comma_separated_names(people) when not is_list(people), do: comma_separated_names([])
  def comma_separated_names(people) do
    # I bet this can be more Elixirey by using head/tail and recursion, but I'm
    # not quite there yet, because the tail case has 2 elements, which I can't
    # quite figure out – JMS
    case length(people) do
      0 -> ""
      1 -> List.first(people).name
      2 -> "#{List.first(people).name} and #{List.last(people).name}"
      _ ->
        last = List.last(people)
        rest = List.delete_at(people, -1)
        commas = Enum.map(rest, &(&1.name)) |> Enum.join(", ")
        "#{commas}, and #{last.name}"
    end
  end

  def external_url(person) do
    cond do
      person.website ->
        person.website
      person.twitter_handle ->
        twitter_url(person.twitter_handle)
      person.github_handle ->
        github_url(person.github_handle)
      true -> "#"
    end
  end
end
