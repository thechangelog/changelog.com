defmodule Changelog.Regexp do
  def http do
    ~r/^https?:\/\//
  end

  def http_message do
    "must include http(s)://"
  end

  def p_tag do
    ~r/<\/?p>/
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

  def transcript_slugs do
    ~r/(?<podcast>.*)\/.*-(?<episode>\w+).md/
  end
end
