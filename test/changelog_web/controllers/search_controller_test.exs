defmodule ChangelogWeb.SearchControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{Typesense}

  import Mock

  def item_to_hit(item) do
    %{
      "document" => %{
        "item_id" => item.id
      },
    }
  end

  describe "without query" do
    test "getting the search" do
      conn = get(build_conn(), Routes.search_path(build_conn(), :search))

      assert conn.status == 200
    end
  end

  describe "with query" do
    test "getting the search with one result" do
      item1 = insert(:published_news_item, headline: "Phoenix", story: "oh my")
      item2 = insert(:published_news_item, headline: "Rails", story: "my oh")
      results = %{
        "hits" => [item_to_hit(item1)],
        "found" => 1,
        "out_of" => 100,
        "page" => 1,
        "request_params" => %{
          "per_page" => 10
        }
      }

      with_mock(Typesense.Client, search: fn _, _ -> {:ok, results} end) do
        conn = get(build_conn(), Routes.search_path(build_conn(), :search, q: "phoenix"))

        assert called(Typesense.Client.search(:_, :meck.is(fn opts -> opts[:q] == "phoenix" end)))
        assert conn.status == 200
        assert conn.resp_body =~ "1 result"
        assert conn.resp_body =~ item1.story
        refute conn.resp_body =~ item2.story
      end
    end

    test "getting the search with multiple results" do
      item1 = insert(:published_news_item, headline: "Phoenix", story: "oh my")
      item2 = insert(:published_news_item, headline: "omg phoenix", story: "my oh")

      results = %{
        "hits" => [item_to_hit(item1), item_to_hit(item2)],
        "found" => 2,
        "out_of" => 100,
        "page" => 1,
        "request_params" => %{
          "per_page" => 10
        }
      }

      with_mock(Typesense.Client, search: fn _, _ -> {:ok, results} end) do
        conn = get(build_conn(), Routes.search_path(build_conn(), :search, q: "phoenix"))

        assert called(Typesense.Client.search(:_, :meck.is(fn opts -> opts[:q] == "phoenix" end)))
        assert conn.status == 200
        assert conn.resp_body =~ "2 results"
        assert conn.resp_body =~ item1.story
        assert conn.resp_body =~ item2.story
      end
    end

    test "getting the search without results" do
      results = %{
        "hits" => [],
        "found" => 0,
        "out_of" => 100,
        "page" => 1,
        "request_params" => %{
          "per_page" => 10
        }
      }

      with_mock(Typesense.Client, search: fn _, _ -> {:ok, results} end) do
        conn = get(build_conn(), Routes.search_path(build_conn(), :search, q: "phoenix"))
        assert called(Typesense.Client.search(:_, :meck.is(fn opts -> opts[:q] == "phoenix" end)))
        assert conn.status == 200
      end
    end
  end
end
