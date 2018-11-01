defmodule Changelog.StringKit do
  def dasherize(string) do
    string
    |> String.downcase
    |> String.replace(~r/[^\w\s]/, "")
    |> String.replace(" ", "-")
  end

  @doc """
  Converts 'bare' links to Markdown-style links for further processing
  """
  def md_linkify(string) do
    regex = ~r/
      (?<=^|\s|\()     # look behind for start of string, space, or left paren
      (https?:\/\/.*?) # capture http url
      (?=$|\s|\))      # look ahead for end of string, space, or right paren
    /x

    Regex.replace(regex, string, ~s{[\\1](\\1)})
  end
end
