defmodule Changelog.StringKitTest do
  use ExUnit.Case

  alias Changelog.StringKit

  test "dasherize" do
    assert StringKit.dasherize("The Changelog") == "the-changelog"
    assert StringKit.dasherize("Go Time") == "go-time"
    assert StringKit.dasherize("Hell's Kitchen!") == "hells-kitchen"
  end

  describe "md_linkify/1" do
    test "no-ops with nothing to linkify" do
      raw = ~s{Yo here is my _super cool_ thing}
      assert StringKit.md_linkify(raw) == raw
    end

    test "no-ops with a link already in there" do
      raw = ~s{So this already has <a href="http://test.com/ohai">http://test.com/ohai</a>}
      assert StringKit.md_linkify(raw) == raw
    end

    test "no-ops with a markdown-style link in there" do
      raw = """
      [When Donald Fischer said](https://changelog.com/founderstalk/58#transcript-73)...
      """
      assert StringKit.md_linkify(raw) == raw
    end

    test "no-ops with a url inside other elements" do
      raw = ~s{<p>http://test.com</p>}
      assert StringKit.md_linkify(raw) == raw
    end

    test "transforms with a single http url" do
      raw = ~s{Yo here is my http://test.com/ohai}
      linkified = ~s{Yo here is my [http://test.com/ohai](http://test.com/ohai)}
      assert StringKit.md_linkify(raw) == linkified
    end

    test "transforms with an http url and an https url" do
      raw = """
      Yo check this out ~> http://test.com/ohai

      Also I dig (https://changelog.com/jsparty), don't you?
      """

      linkified = """
      Yo check this out ~> [http://test.com/ohai](http://test.com/ohai)

      Also I dig ([https://changelog.com/jsparty](https://changelog.com/jsparty)), don't you?
      """

      assert StringKit.md_linkify(raw) == linkified
    end

    test "transforms with muliple links surrounded by newlines" do
      raw = """
      http://test.com/1
      http://test.com/2
      http://test.com/3
      """

      linkified = """
      [http://test.com/1](http://test.com/1)
      [http://test.com/2](http://test.com/2)
      [http://test.com/3](http://test.com/3)
      """

      assert StringKit.md_linkify(raw) == linkified
    end
  end
end
