defmodule Changelog.Regexp do
  def email, do: ~r/^\S+@\S+\.\S+$/

  def http, do: ~r/^https?:\/\//

  def http_message, do: "must include http(s)://"

  def tag, do: ~r/(?<open><\/?)(?<tag>.*?)(?<close>>)/

  def tag(name), do: ~r/(?<open><\/?)#{name}(?<close>>)/

  def slug, do: ~r/\A[a-z|0-9|_|-]+\z/

  def slug_message, do: "valid chars: a-z, 0-9, -, _"

  def timestamp, do: ~r/(\d\d:)?(\d\d?:)(\d\d)(\.\d\d?)?/
end
