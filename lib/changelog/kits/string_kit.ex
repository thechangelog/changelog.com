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
      (?<=^|\s|\()     # positive look behind: start of string | space | left paren
      (?<!]\()         # negative look behind: '[(' (existing md link)
      (https?:\/\/.*?) # capture http(s) url
      (?=$|\s|\))      # positive look ahead: end of string | space | right paren
    /x

    Regex.replace(regex, string, ~s{[\\1](\\1)})
  end
end
