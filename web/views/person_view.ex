defmodule Changelog.PersonView do
  use Changelog.Web, :view

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
