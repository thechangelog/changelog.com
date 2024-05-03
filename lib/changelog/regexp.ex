defmodule Changelog.Regexp do
  def cache_buster, do: ~r/\?v=.*\z/

  def email, do: ~r/^[^@ ]+@[^ ]+\.[^ ]+$/

  def email_message, do: "must be a valid email address"

  def http, do: ~r/^https?:\/\//

  def http_message, do: "must include http(s)://"

  def tag, do: ~r/(?<open><\/?)(?<tag>.*?)(?<close>>)/

  def tag(name), do: ~r/(?<open><\/?)#{name}(?<close>>)/

  def social, do: ~r/\A[a-z|A-Z|0-9|_|-]+\z/

  def social_message, do: "just the username, plz"

  def slug, do: ~r/\A[a-z|0-9|_|-]+\z/

  def slug_message, do: "valid chars: a-z, 0-9, -, _"

  def timestamp, do: ~r/(\d\d:)?(\d\d?:)(\d\d)(\.\d\d?)?/

  def top_story, do: ~r/\A###?\s(\X+)\s\[/

  def new_line, do: ~r/\r?\n/
end
