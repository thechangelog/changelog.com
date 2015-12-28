defmodule Changelog.Regexp do
  def slug do
    ~r/\A[a-z|0-9|_|-]+\z/
  end

  def slug_message do
    "valid chars: a-z, 0-9, -, _"
  end

  def http do
    ~r/^https?:\/\//
  end

  def http_message do
    "must include http(s)://"
  end
end
