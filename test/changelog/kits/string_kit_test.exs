defmodule Changelog.StringKitTest do
  use ExUnit.Case

  alias Changelog.StringKit

  test "blank?/1" do
    assert StringKit.blank?(nil)
    assert StringKit.blank?("")
    assert StringKit.blank?("     ")
    refute StringKit.blank?("stuff")
  end

  test "is_integer/1" do
    assert StringKit.is_integer("123")
    refute StringKit.is_integer("")
    refute StringKit.is_integer("not-a-number")
    refute StringKit.is_integer("95a8fbc221a2240ac7469d661bac650a")
  end

  test "present?/1" do
    refute StringKit.present?(nil)
    refute StringKit.present?("")
    refute StringKit.present?("     ")
    assert StringKit.present?("stuff")
  end

  test "dasherize/1" do
    assert StringKit.dasherize("The Changelog") == "the-changelog"
    assert StringKit.dasherize("Go Time") == "go-time"
    assert StringKit.dasherize("Hell's Kitchen!") == "hells-kitchen"
  end

  describe "extract_mentions/1" do
    test "returns an empty list when there aren't any" do
      raw = ~s{Yo here is my _super cool_ thing}
      assert StringKit.extract_mentions(raw) == []
    end

    test "returns one mention when string has one" do
      raw = """
      @kball representing the JS Party community in Amsterdam?! Yes please.
      """

      assert StringKit.extract_mentions(raw) == ["kball"]
    end

    test "returns multiple mentions when separated by commas" do
      raw = """
      I think we should pull in @jerodsanto, @codyjames, and @adamstac!
      """

      assert StringKit.extract_mentions(raw) == ["jerodsanto", "codyjames", "adamstac"]
    end

    test "returns a mention when it is at the end of a sentence" do
      raw = """
      I blame @matryer. Not because I think he planned it, but because I enjoy blaming him for things.
      """

      assert StringKit.extract_mentions(raw) == ["matryer"]
    end

    test "does not return a mention when part of email address" do
      raw = """
      Shoot me an email at hi@gerhard.io or just mention me @gerhard
      """

      assert StringKit.extract_mentions(raw) == ["gerhard"]
    end
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

    test "transforms with a single https url followed by punctuation" do
      raw = """
      read Turing Award lectures - https://amturing.acm.org/lectures.cfm?
      """

      linkified = """
      read Turing Award lectures - [https://amturing.acm.org/lectures.cfm](https://amturing.acm.org/lectures.cfm)?
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

  describe "md_delinkify/1" do
    test "it leaves strings with no links in them alone" do
      raw = "this has zero ! links."
      assert StringKit.md_delinkify(raw) == raw
    end

    test "it works with a single link in there" do
      a = "This has [one](http://test.com) link and that's it"
      b = "This has one link and that's it"

      assert StringKit.md_delinkify(a) == b
    end

    test "it works with multiple links in there" do
      a = "This has [two](http://test.com) links and that's [all](http://www.com)."
      b = "This has two links and that's all."

      assert StringKit.md_delinkify(a) == b
    end
  end

  describe "md_bare_linkify/1" do
    test "it leaves strings with no links in them alone" do
      raw = "this has zero ! links."
      assert StringKit.md_bare_linkify(raw) == raw
    end

    test "it works with a single link in there" do
      a = "This has [one](http://test.com) link and that's it"
      b = "This has http://test.com link and that's it"

      assert StringKit.md_bare_linkify(a) == b
    end

    test "it works with multiple links in there" do
      a = "This has [two](http://test.com) links and that's [all](http://www.com)."
      b = "This has http://test.com links and that's http://www.com."

      assert StringKit.md_bare_linkify(a) == b
    end
  end

  describe "mentions_linkify/1" do
    test "it no-ops when no mentions to linkify" do
      raw = ~s{Yo here is my _super cool_ thing}
      assert StringKit.mentions_linkify(raw, []) == raw
    end

    test "it no-ops when it has a mention but they aren't a known person" do
      raw = """
      @kball representing the JS Party community in Amsterdam?! Yes please.
      """

      assert StringKit.mentions_linkify(raw, []) == raw
    end

    test "it replaces one mention with the appropriate markdown-style link" do
      kball = %{handle: "kball"}

      raw = """
      @kball representing the JS Party community in Amsterdam?! Yes please.
      """

      linkified = """
      [@kball](/person/kball) representing the JS Party community in Amsterdam?! Yes please.
      """

      assert StringKit.mentions_linkify(raw, [kball]) == linkified
    end

    test "it replaces multiple mentions with the appropriate markdown-style link" do
      jerodsanto = %{handle: "jerodsanto"}
      adamstac = %{handle: "adamstac"}

      raw = """
      Well that is awesome @adamstac @jerodsanto, thanks!
      """

      linkified = """
      Well that is awesome [@adamstac](/person/adamstac) [@jerodsanto](/person/jerodsanto), thanks!
      """

      assert StringKit.mentions_linkify(raw, [jerodsanto, adamstac]) == linkified
    end
  end
end
