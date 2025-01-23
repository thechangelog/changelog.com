defmodule Changelog.StringKit do
  alias ChangelogWeb.{Endpoint, Router}

  def blank?(nil), do: true

  def blank?(string) when is_binary(string), do: String.trim(string) == ""

  def blank?(_unknown), do: false

  def dasherize(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^\w\s]/, "")
    |> String.replace(" ", "-")
  end

  @doc """
  Returns a list of sub-strings that are possible mentions for further processing
  """
  def extract_mentions(string) do
    regex = ~r/
    @([a-z|0-9|_|-]+) # capture @ followed by valid username chars
    (?!\.\w)          # negative look ahead: a period followed by a word char, which indicates email address
    \W                # lastly a non-word char, indicating the end of mention
    /x

    regex
    |> Regex.scan(string)
    |> Enum.map(&List.last/1)
  end

  @doc """
  Returns true if the given string represents an integer, false otherwise
  """
  def is_integer(string) do
    try do
      _ = String.to_integer(string)
      true
    rescue
      _ -> false
    end
  end

  @doc """
  Converts 'bare' links to Markdown-style links for further processing
  """
  def md_linkify(string) do
    regex = ~r/
      (?<=^|\s|\()     # positive look behind: start of string | space | left paren
      (?<!]\()         # negative look behind: '[(' (existing md link)
      (https?:\/\/.*?) # capture http(s) url
      (?=$|\s|\W\s|\)) # positive look ahead: end of string | space | nonword-space | right paren
    /x

    Regex.replace(regex, string, ~s{[\\1](\\1)})
  end

  @doc """
  Removes Markdown-style links from a string
  """
  def md_delinkify(string) do
    regex = ~r/\[(.*?)\]\(.*?\)/

    Regex.replace(regex, string, "\\1")
  end

  @doc """
  Removes Markdown-style descriptions from a link. Opposite of `md_delinkify`
  """
  def md_bare_linkify(string) do
    regex = ~r/\[(.*?)\]\((.*?)\)/

    Regex.replace(regex, string, "\\2")
  end

  @doc """
  Converts 'bare' mentions to Markdown-style links for further processing
  """
  def mentions_linkify(string, []), do: string

  def mentions_linkify(string, people) do
    Enum.reduce(people, string, fn person, string ->
      mention = "@#{person.handle}"
      url = Router.Helpers.person_path(Endpoint, :show, person.handle)
      String.replace(string, "#{mention}", "[#{mention}](#{url})")
    end)
  end

  def present?(string), do: !blank?(string)
end
