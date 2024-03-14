defmodule Changelog.HtmlKitTest do
  use ExUnit.Case

  alias Changelog.HtmlKit

  describe "get_title/1" do
    test "defaults to empty string" do
      assert HtmlKit.get_title(nil) == ""
      assert HtmlKit.get_title("") == ""
    end

    test "when title tag has attrs" do
      html = ~s{<title itemprop='name'>October's Best Gear</title>}
      assert HtmlKit.get_title(html) == "October's Best Gear"
    end

    test "when newlines are a thing" do
      html = """
      <head>
      <meta charset="utf-8">
      <title>
      GraphQL + Relay Modern + Rails //
      Collective Idea
      | Crafting web and mobile software based in Holland, Michigan
      </title>
      """

      assert HtmlKit.get_title(html) == "GraphQL + Relay Modern + Rails //"
    end

    test "when there are multiple title tags" do
      html =
        "<title>Are holograms the future of how we capture memories?</title><title>Part Deux</title."

      assert HtmlKit.get_title(html) == "Are holograms the future of how we capture memories?"
    end
  end

  describe "get_images/1" do
    test "defaults to empty list" do
      assert HtmlKit.get_images(nil) == []
    end

    test "returns empty list when there aren't any" do
      html = "<html><body><h1>O'DOYLE RULES</h1></body></html>"
      assert HtmlKit.get_images(html) == []
    end

    test "returns a single image source when there's just one" do
      html = """
      <html>
        <body>
          <h1>O'DOYLE RULES</h1><p><img name="ohai" src="/test/example.jpg"></p>
        </body>
      </html>
      """

      assert HtmlKit.get_images(html) == ["/test/example.jpg"]
    end

    test "returns multiple image sources when there are a bunch" do
      html = """
      <img name="ohai" src="/test/example.jpg">
      <img src="http://example.com/test.png">
      <img src="https://blech.com/test.svg">
      <img class=crazy src=/blech/test.png>
      """

      assert HtmlKit.get_images(html) == [
               "/test/example.jpg",
               "http://example.com/test.png",
               "https://blech.com/test.svg",
               "/blech/test.png"
             ]
    end
  end

  describe "put_a_rel/2" do
    test "does nothing if there are no anchors" do
      assert HtmlKit.put_a_rel("<html></html>", "nofollow") == "<html></html>"
    end

    test "it adds rel='external sponsored' to a single anchor" do
      a = ~s(<div><h1><a href="test.com">ohai</a></h1></div>)
      b = ~s(<div><h1><a rel="external sponsored" href="test.com">ohai</a></h1></div>)
      assert HtmlKit.put_a_rel(a, "external sponsored") == b
    end

    test "it adds rel='ugc' to multiple anchors" do
      a = ~s(<a href="">ohai there</a>  <a href="">obai there</a>)
      b = ~s(<a rel="ugc" href="">ohai there</a><a rel="ugc" href="">obai there</a>)
      assert HtmlKit.put_a_rel(a, "ugc") == b
    end
  end

  describe "put_img_width/2" do
    test "does nothing if there are no img tags" do
      assert HtmlKit.put_img_width("<html></html>", 500) == "<html></html>"
    end

    test "it adds width to a single img" do
      a = ~s(<div><h1><img src="/example.png"></h1></div>)
      b = ~s(<div><h1><img width="500" src="/example.png"/></h1></div>)
      assert HtmlKit.put_img_width(a, 500) == b
    end

    test "it adds width to multiple img tags" do
      a = ~s(<img src="/test1.png"> (<img src="/test2.png">)
      b = ~s(<img width="250" src="/test1.png"/> (<img width="250" src="/test2.png"/>)
      assert HtmlKit.put_img_width(a, "250") == b
    end
  end

  describe "put_utm_source/2" do
    test "it does nothing if there are no anchors" do
      assert HtmlKit.put_utm_source("<html></html>", "changelog-news") == "<html></html>"
    end

    test "it adds utm_source to a single anchor" do
      a = ~s(<div><h1><a href="test.com">ohai</a></h1></div>)
      b = ~s(<div><h1><a href="test.com?utm_source=ohai">ohai</a></h1></div>)
      assert HtmlKit.put_utm_source(a, "ohai") == b
    end

    test "it adds utm_source to multiple anchors" do
      a =
        ~s(<a href="https://changelog.com">ohai there</a>  <a href="https://test.com">obai there</a>)

      b =
        ~s(<a href="https://changelog.com?utm_source=test">ohai there</a><a href="https://test.com?utm_source=test">obai there</a>)

      assert HtmlKit.put_utm_source(a, "test") == b
    end

    test "it skips anchors that are have utm" do
      a =
        ~s(<a href="https://changelog.com?utm_medium=nope">ohai there</a>  <a href="https://test.com">obai there</a>)

      b =
        ~s(<a href="https://changelog.com?utm_medium=nope">ohai there</a><a href="https://test.com?utm_source=test">obai there</a>)

      assert HtmlKit.put_utm_source(a, "test") == b
    end

    test "it doesn't clobber other valid query params" do
      a = ~s(<a href="https://www.youtube.com/watch?v=GWYhtksrmhE">cool video</a>)
      b = ~s(<a href="https://www.youtube.com/watch?utm_source=test&v=GWYhtksrmhE">cool video</a>)
      assert HtmlKit.put_utm_source(a, "test") == b
    end
  end
end
