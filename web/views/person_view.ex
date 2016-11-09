defmodule Changelog.PersonView do
  use Changelog.Web, :view

  def avatar_url(person), do: avatar_url(person, :small)
  def avatar_url(person, version) do
    if person.avatar do
      Changelog.Avatar.url({person.avatar, person}, version)
      |> String.replace_leading("/priv", "/")
      |> String.replace(~r{^//}, "/") # Arc 0.6 now prepends / to *all* URLs
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

  def list_of_links(person) do
    [%{value: person.twitter_handle, text: "Twitter", url: twitter_url(person.twitter_handle)},
     %{value: person.github_handle, text: "GitHub", url: github_url(person.github_handle)},
     %{value: person.website, text: "Website", url: person.website}]
    |> Enum.reject(fn(x) -> x.value == nil end)
    |> Enum.map(fn(x) -> link(x.text, to: x.url) end)
    |> Enum.map(fn({:safe, list}) -> Enum.join(list) end)
    |> Enum.join(", ")
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
