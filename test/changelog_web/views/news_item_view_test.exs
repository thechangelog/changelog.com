defmodule ChangelogWeb.NewstemViewTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.NewsItemView

  alias Changelog.NewsItem

  describe "teaser" do
    test "leaves stories alone that are shorter than given words length" do
      story = ~s{A fun read, but does it fall pray to [Betteridge's Law of Headlines](https://en.wikipedia.org/wiki/Betteridge%27s_law_of_headlines)? 😏}
      tease = ~s{A fun read, but does it fall pray to <a href="https://en.wikipedia.org/wiki/Betteridge%27s_law_of_headlines">Betteridge's Law of Headlines</a>? 😏}
      assert teaser(story) == tease
    end

    test "shortens stories that are longer than given words length" do
      story = "Y'all know we like Awesome lists around these parts. What's better? _Meta-Awesome lists_."
      tease = "Y'all know we like Awesome lists around these parts. What's better? ..."
      assert teaser(story, 11) == tease
    end

    test "replaces blockquotes with italics, removes paragraphs" do
      story = """
      > A minimal subset of JSON for machine-to-machine communication

      I didn't know this problem existed:

      > JSON contains redundant syntax such as allowing both 10e2 and 10E2. This helps when writing it by hand but isn't good for machine-to-machine communication.

      Now that I know, I'm glad a solution exists, _son_.
      """
      tease = ~s{<i>A minimal subset of JSON for machine-to-machine communication</i> I didn't know this problem existed: <i>JSON contains redundant syntax such as </i> ...}

      assert teaser(story) == tease
    end
  end

  describe "slug" do
    test "downcases, removes non-alpha-numeric, converts spaces to dashes, appends hashid" do
      assert slug(%NewsItem{id: 1, headline: "Oh! Wow?"}) == "oh-wow-z4"
      assert slug(%NewsItem{id: 1, headline: "ZOMG 🙌 an ^emoJI@"}) == "zomg-an-emoji-z4"
      assert slug(%NewsItem{id: 1, headline: "The 4 best things EVAR"}) == "the-4-best-things-evar-z4"
    end
  end
end
