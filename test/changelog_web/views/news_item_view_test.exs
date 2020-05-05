defmodule ChangelogWeb.NewstemViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.NewsItemView

  describe "object_path/1" do
    test "defaults to nil when object is nil" do
      item = build(:news_item, object_id: nil)
      assert is_nil(NewsItemView.object_path(item))
    end

    test "reconstructs audio urls" do
      podcast = insert(:podcast, slug: "test1")
      episode = insert(:episode, podcast: podcast, slug: "test2")
      item = episode |> episode_news_item() |> insert()
      assert NewsItemView.object_path(item) == "/test1/test2"
    end

    test "reconstructs post urls" do
      item = build(:news_item, object_id: "posts:oscon-2017-free-pass")
      assert NewsItemView.object_path(item) == "/posts/oscon-2017-free-pass"
    end
  end

  describe "teaser" do
    test "leaves stories alone that are shorter than given words length" do
      item = %{
        story:
          ~s{A fun read, but does it fall pray to [Betteridge's Law of Headlines](https://en.wikipedia.org/wiki/Betteridge%27s_law_of_headlines)? 😏}
      }

      tease =
        ~s{A fun read, but does it fall pray to <a href="https://en.wikipedia.org/wiki/Betteridge%27s_law_of_headlines">Betteridge’s Law of Headlines</a>? 😏}

      assert NewsItemView.teaser(item) == tease
    end

    test "shortens stories that are longer than given words length" do
      item = %{
        story:
          "Y'all know we like Awesome lists around these parts. What's better? _Meta-Awesome lists_."
      }

      tease = "Y’all know we like Awesome lists around these parts. What’s better? ..."
      assert NewsItemView.teaser(item, 11) == tease
    end

    test "replaces blockquotes with italics, removes paragraphs" do
      item = %{
        story: """
        > A minimal subset of JSON for machine-to-machine communication

        I didn't know this problem existed:

        > JSON contains redundant syntax such as allowing both 10e2 and 10E2. This helps when writing it by hand but isn't good for machine-to-machine communication.

        Now that I know, I'm glad a solution exists, _son_.
        """
      }

      tease =
        ~s{<i>A minimal subset of JSON for machine-to-machine communication</i> I didn’t know this problem existed: <i>JSON contains redundant syntax such as </i> ...}

      assert NewsItemView.teaser(item) == tease
    end
  end
end
