defmodule Changelog.StringKitTest do
  use ExUnit.Case

  alias Changelog.StringKit

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
      kball = %{handle: "kball", website: "https://zendev.com"}

      raw = """
      @kball representing the JS Party community in Amsterdam?! Yes please.
      """

      linkified = """
      [@kball](https://zendev.com) representing the JS Party community in Amsterdam?! Yes please.
      """
      assert StringKit.mentions_linkify(raw, [kball]) == linkified
    end

    test "it replaces multiple mentions with the appropriate markdown-style link" do
      jerodsanto = %{handle: "jerodsanto", website: "https://jerodsanto.net"}
      adamstac = %{handle: "adamstac", website: "https://adamstacoviak.com"}

      raw = """
      Well that is awesome @adamstac @jerodsanto, thanks!
      """

      linkified = """
      Well that is awesome [@adamstac](https://adamstacoviak.com) [@jerodsanto](https://jerodsanto.net), thanks!
      """

      assert StringKit.mentions_linkify(raw, [jerodsanto, adamstac]) == linkified
    end
  end
end
