defmodule Changelog.Regexp do
  # via https://gist.github.com/mgamini/4f3a8bc55bdcc96be2c6
  def email do
    ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]+$/
  end

  def http do
    ~r/^https?:\/\//
  end

  def http_message do
    "must include http(s)://"
  end

  def tag do
    ~r/(?<open><\/?)(?<tag>.*?)(?<close>>)/
  end

  def tag(name) do
    ~r/(?<open><\/?)#{name}(?<close>>)/
  end

  def slug do
    ~r/\A[a-z|0-9|_|-]+\z/
  end

  def slug_message do
    "valid chars: a-z, 0-9, -, _"
  end

  def timestamp do
    ~r/(\d\d:)?(\d\d?:)(\d\d)(\.\d\d?)?/
  end

  def github_filename_slugs do
    ~r/(?<podcast>.*)\/.*-(?<episode>\w+).md/
  end
end
