defmodule Changelog.Metacasts.Filterer.GeneratorTest do
  use ExUnit.Case
  doctest Changelog.Metacasts.Filterer.Generator

  alias Changelog.Metacasts.Filterer.{Generator, Representation, FacetStatement, Parser}

  @except %Representation{
    start: :except,
    statements: [
      %FacetStatement{
        items: ["gotime", "rfc", "afk"],
        logic: :or,
        repr: :podcast
      },
      %FacetStatement{
        items: ["react", "react-native", "typescript"],
        logic: :or,
        repr: :topic
      },
      %FacetStatement{
        items: ["Jason Fried", "Steve Jobs"],
        logic: :or,
        repr: :guest
      },
      %FacetStatement{items: ["jsparty"], logic: :and, repr: :podcast},
      {:sub_facet_start, :unless},
      {:sub_facet_logic, :or},
      %FacetStatement{items: ["Suz Hinton", "KBall"], logic: :or, repr: :host},
      {:sub_facet_start, :if},
      {:sub_facet_logic, :or},
      %FacetStatement{
        items: ["webrtc", "streaming"],
        logic: :or,
        repr: :topic
      },
      %FacetStatement{items: ["golf"], logic: :and, repr: :topic},
      %FacetStatement{items: ["code"], logic: :and, repr: :topic},
      :sub_facet_end,
      %FacetStatement{items: ["svelte"], logic: :and, repr: :topic},
      %FacetStatement{
        items: ["phoenix", "liveview"],
        logic: :and,
        repr: :topic
      },
      :sub_facet_end,
      %FacetStatement{items: ["changelog"], logic: :and, repr: :podcast}
    ]
  }

  @only %Representation{
    start: :only,
    statements: [
      %FacetStatement{
        items: ["gotime", "rfc", "afk"],
        logic: :and,
        repr: :podcast
      },
      %FacetStatement{
        items: ["react", "react-native", "typescript"],
        logic: :or,
        repr: :topic
      },
      %FacetStatement{
        items: ["Jason Fried", "Steve Jobs"],
        logic: :or,
        repr: :guest
      },
      %FacetStatement{items: ["jsparty"], logic: :and, repr: :podcast},
      {:sub_facet_start, :unless},
      {:sub_facet_logic, :or},
      %FacetStatement{items: ["Suz Hinton", "KBall"], logic: :or, repr: :host},
      {:sub_facet_start, :if},
      {:sub_facet_logic, :or},
      %FacetStatement{
        items: ["webrtc", "streaming"],
        logic: :or,
        repr: :topic
      },
      %FacetStatement{items: ["golf"], logic: :and, repr: :topic},
      %FacetStatement{items: ["code"], logic: :and, repr: :topic},
      :sub_facet_end,
      %FacetStatement{items: ["svelte"], logic: :and, repr: :topic},
      %FacetStatement{
        items: ["phoenix", "liveview"],
        logic: :and,
        repr: :topic
      },
      :sub_facet_end,
      %FacetStatement{items: ["changelog"], logic: :and, repr: :podcast}
    ]
  }

  @samples [
    %{
      id: :weird_one,
      podcast: "somethingelse",
      topic: ["entirelydifferent"],
      host: ["No one you know"],
      guest: ["Unknown entity"]
    },
    %{
      id: :weird_two,
      podcast: "somethingelser",
      topic: ["entirelydifferent"],
      host: ["No one you know"],
      guest: ["Unknown entity"]
    },
    %{
      id: :jobs_only,
      podcast: "somethingelse",
      topic: [],
      host: [],
      guest: ["Steve Jobs"]
    },
    %{
      id: :gotime_only,
      podcast: "gotime",
      topic: [],
      host: [],
      guest: []
    },
    %{
      id: :jsparty_only,
      podcast: "jsparty",
      topic: [],
      host: [],
      guest: []
    },
    %{
      id: :jsparty_jerod_only,
      podcast: "jsparty",
      topic: [],
      host: "Jerod Santo",
      guest: []
    },
    %{
      id: :jsparty_suz_only,
      podcast: "jsparty",
      topic: [],
      host: "Suz Hinton",
      guest: []
    },
    %{
      id: :jsparty_suz_webrtc,
      podcast: "jsparty",
      topic: ["webrtc"],
      host: "Suz Hinton",
      guest: []
    },
    %{
      id: :jsparty_kball_golf,
      podcast: "jsparty",
      topic: ["golf"],
      host: ["KBall"],
      guest: []
    },
    %{
      id: :jsparty_svelte,
      podcast: "jsparty",
      topic: ["svelte"],
      host: [],
      guest: []
    },
    %{
      id: :jsparty_svelte_angular,
      podcast: "jsparty",
      topic: ["svelte", "angular"],
      host: [],
      guest: []
    },
    %{
      id: :jsparty_phoenix_liveview,
      podcast: "jsparty",
      topic: ["phoenix", "liveview"],
      host: [],
      guest: []
    },
    %{
      id: :jsparty_phoenix_only,
      podcast: "jsparty",
      topic: ["phoenix"],
      host: [],
      guest: []
    },
    %{
      id: :kubernetes_only,
      podcast: "doesntmatter",
      topic: ["kubernetes"],
      host: [],
      guest: []
    }
  ]

  @minimal %Representation{
    start: :except,
    statements: []
  }

  test "except" do
    stream_filter = Generator.generate_stream_filters(@except)
    assert [
      :weird_one,
      :weird_two,
      :jsparty_suz_webrtc,
      :jsparty_kball_golf,
      :jsparty_svelte,
      :jsparty_svelte_angular,
      :jsparty_phoenix_liveview,
      :kubernetes_only
    ] = filter_to_ids(@samples, stream_filter)
  end

  test "only" do
    stream_filter = Generator.generate_stream_filters(@only)
    assert [
      :jobs_only,
      :jsparty_only,
      :jsparty_jerod_only,
      :jsparty_suz_only,
      :jsparty_phoenix_only
    ] = filter_to_ids(@samples, stream_filter)
  end

  test "kubernetes, end-to-end" do
    stream_filter = "only topic: kubernetes"
    |> Parser.parse()
    |> elem(1)
    |> Generator.generate_stream_filters()

    assert [
      :kubernetes_only
    ] = filter_to_ids(@samples, stream_filter)
  end

  test "minimal" do
    stream_filter = Generator.generate_stream_filters(@minimal)
    assert @samples = stream_filter.(@samples) |> Enum.to_list()
  end

  defp filter_to_ids(samples, filter) do
    samples
    |> filter.()
    |> Enum.to_list()
    |> Enum.map(fn item ->
      Map.get(item, :id, nil)
    end)
  end
end
