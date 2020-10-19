defmodule Changelog.Metacasts.Filterer.ParserTest do
  use ExUnit.Case
  doctest Changelog.Metacasts.Filterer.Parser

  alias Changelog.Metacasts.Filterer
  alias Changelog.Metacasts.Filterer.Parser

  @except """
  except
  podcast: gotime, rfc or afk
  topic: react, react-native or typescript
  guest: "Jason Fried" or "Steve Jobs"
  podcast: jsparty
  unless any (
    host: "Suz Hinton" or "KBall" if any (
      topic: webrtc or streaming
      topic: golf
      topic: code
    )
    topic: svelte
    topic: phoenix and liveview
  )
  podcast: changelog
  """

  @only """
  only
  podcast: gotime, rfc and afk
  topic: react, react-native or typescript
  guest: "Jason Fried" or "Steve Jobs"
  podcast: jsparty
  unless any (
    host: "Suz Hinton" or "KBall" if any (
      topic: webrtc or streaming
      topic: golf
      topic: code
    )
    topic: svelte
    topic: phoenix and liveview
  )
  podcast: changelog
  """

  @inline "only podcast: gotime, rfc and afk topic: react, react-native or typescript guest: \"Jason Fried\" or \"Steve Jobs\" podcast: jsparty unless any ( host: \"Suz Hinton\" or \"KBall\" topic: svelte topic: phoenix and liveview ) podcast: changelog"
  @inline_tight_parens "only podcast: gotime, rfc and afk topic: react, react-native or typescript guest: \"Jason Fried\" or \"Steve Jobs\" podcast: jsparty unless any (host: \"Suz Hinton\" or \"KBall\" topic: svelte topic: phoenix and liveview) podcast: changelog"
  @minimal "except"
  @empty ""

  test "except" do
    assert {:ok,
            %Filterer.Representation{
              start: :except,
              statements: [
                %Filterer.FacetStatement{
                  items: ["gotime", "rfc", "afk"],
                  logic: :or,
                  repr: :podcast
                },
                %Filterer.FacetStatement{
                  items: ["react", "react-native", "typescript"],
                  logic: :or,
                  repr: :topic
                },
                %Filterer.FacetStatement{
                  items: ["Jason Fried", "Steve Jobs"],
                  logic: :or,
                  repr: :guest
                },
                %Filterer.FacetStatement{items: ["jsparty"], logic: :and, repr: :podcast},
                {:sub_facet_start, :unless},
                {:sub_facet_logic, :or},
                %Filterer.FacetStatement{items: ["Suz Hinton", "KBall"], logic: :or, repr: :host},
                {:sub_facet_start, :if},
                {:sub_facet_logic, :or},
                %Filterer.FacetStatement{
                  items: ["webrtc", "streaming"],
                  logic: :or,
                  repr: :topic
                },
                %Filterer.FacetStatement{items: ["golf"], logic: :and, repr: :topic},
                %Filterer.FacetStatement{items: ["code"], logic: :and, repr: :topic},
                :sub_facet_end,
                %Filterer.FacetStatement{items: ["svelte"], logic: :and, repr: :topic},
                %Filterer.FacetStatement{
                  items: ["phoenix", "liveview"],
                  logic: :and,
                  repr: :topic
                },
                :sub_facet_end,
                %Filterer.FacetStatement{items: ["changelog"], logic: :and, repr: :podcast}
              ]
            }} = Parser.parse(@except)
  end

  test "only" do
    assert {:ok,
            %Filterer.Representation{
              start: :only,
              statements: [
                %Filterer.FacetStatement{
                  items: ["gotime", "rfc", "afk"],
                  logic: :and,
                  repr: :podcast
                },
                %Filterer.FacetStatement{
                  items: ["react", "react-native", "typescript"],
                  logic: :or,
                  repr: :topic
                },
                %Filterer.FacetStatement{
                  items: ["Jason Fried", "Steve Jobs"],
                  logic: :or,
                  repr: :guest
                },
                %Filterer.FacetStatement{items: ["jsparty"], logic: :and, repr: :podcast},
                {:sub_facet_start, :unless},
                {:sub_facet_logic, :or},
                %Filterer.FacetStatement{items: ["Suz Hinton", "KBall"], logic: :or, repr: :host},
                {:sub_facet_start, :if},
                {:sub_facet_logic, :or},
                %Filterer.FacetStatement{
                  items: ["webrtc", "streaming"],
                  logic: :or,
                  repr: :topic
                },
                %Filterer.FacetStatement{items: ["golf"], logic: :and, repr: :topic},
                %Filterer.FacetStatement{items: ["code"], logic: :and, repr: :topic},
                :sub_facet_end,
                %Filterer.FacetStatement{items: ["svelte"], logic: :and, repr: :topic},
                %Filterer.FacetStatement{
                  items: ["phoenix", "liveview"],
                  logic: :and,
                  repr: :topic
                },
                :sub_facet_end,
                %Filterer.FacetStatement{items: ["changelog"], logic: :and, repr: :podcast}
              ]
            }} = Parser.parse(@only)
  end

  test "inline" do
    assert {:ok,
            %Filterer.Representation{
              start: :only,
              statements: [
                %Filterer.FacetStatement{
                  items: ["gotime", "rfc", "afk"],
                  logic: :and,
                  repr: :podcast
                },
                %Filterer.FacetStatement{
                  items: ["react", "react-native", "typescript"],
                  logic: :or,
                  repr: :topic
                },
                %Filterer.FacetStatement{
                  items: ["Jason Fried", "Steve Jobs"],
                  logic: :or,
                  repr: :guest
                },
                %Filterer.FacetStatement{items: ["jsparty"], logic: :and, repr: :podcast},
                {:sub_facet_start, :unless},
                {:sub_facet_logic, :or},
                %Filterer.FacetStatement{items: ["Suz Hinton", "KBall"], logic: :or, repr: :host},
                %Filterer.FacetStatement{items: ["svelte"], logic: :and, repr: :topic},
                %Filterer.FacetStatement{
                  items: ["phoenix", "liveview"],
                  logic: :and,
                  repr: :topic
                },
                :sub_facet_end,
                %Filterer.FacetStatement{items: ["changelog"], logic: :and, repr: :podcast}
              ]
            }} = Parser.parse(@inline)
  end

  test "inline tight parens" do
    assert {:ok,
            %Filterer.Representation{
              start: :only,
              statements: [
                %Filterer.FacetStatement{
                  items: ["gotime", "rfc", "afk"],
                  logic: :and,
                  repr: :podcast
                },
                %Filterer.FacetStatement{
                  items: ["react", "react-native", "typescript"],
                  logic: :or,
                  repr: :topic
                },
                %Filterer.FacetStatement{
                  items: ["Jason Fried", "Steve Jobs"],
                  logic: :or,
                  repr: :guest
                },
                %Filterer.FacetStatement{items: ["jsparty"], logic: :and, repr: :podcast},
                {:sub_facet_start, :unless},
                {:sub_facet_logic, :or},
                %Filterer.FacetStatement{items: ["Suz Hinton", "KBall"], logic: :or, repr: :host},
                %Filterer.FacetStatement{items: ["svelte"], logic: :and, repr: :topic},
                %Filterer.FacetStatement{
                  items: ["phoenix", "liveview"],
                  logic: :and,
                  repr: :topic
                },
                :sub_facet_end,
                %Filterer.FacetStatement{items: ["changelog"], logic: :and, repr: :podcast}
              ]
            }} = Parser.parse(@inline_tight_parens)
  end

  test "minimal" do
    assert {:ok,
            %Filterer.Representation{
              start: :except,
              statements: []
            }} = Parser.parse(@minimal)
  end

  test "empty" do
    assert {:error, :no_start} = Parser.parse(@empty)
  end
end
