defmodule Changelog.Transcripts.ParserTest do
  use ExUnit.Case
  import Changelog.TestCase

  alias Changelog.Person
  alias Changelog.Transcripts.Parser

  test "parsing an empty string" do
    parsed = Parser.parse_text("")
    assert Enum.empty?(parsed)
  end

  test "parsing nil" do
    parsed = Parser.parse_text(nil)
    assert Enum.empty?(parsed)
  end

  test "parsing The Changelog 200" do
    adam = %Person{id: 1, name: "Adam Stacoviak"}
    jerod = %Person{id: 2, name: "Jerod Santo"}
    raquel = %Person{id: 3, name: "Raquel Vélez"}

    text = File.read!("#{fixtures_path()}/transcripts/the-changelog-200.md")

    parsed = Parser.parse_text(text, [adam, jerod, raquel])

    assert length(parsed) == 181

    people_ids =
      parsed
      |> Enum.map(&(&1.person_id))
      |> Enum.uniq
      |> Enum.reject(&is_nil/1)

    assert people_ids == [adam.id, jerod.id, raquel.id]

    titles =
      parsed
      |> Enum.map(&(&1.title))
      |> Enum.uniq

    assert titles == ["Adam Stacoviak", "Jerod Santo", "Raquel Vélez", "Break"]
  end

  test "JS Party 1" do
    alex   = %Person{id: 1, name: "Alex Sexton"}
    mikeal = %Person{id: 2, name: "Mikeal Rogers"}
    rachel = %Person{id: 3, name: "Rachel White"}

    text = File.read!("#{fixtures_path()}/transcripts/js-party-1.md")

    parsed = Parser.parse_text(text, [alex, mikeal, rachel])

    assert length(parsed) == 185

    people_ids =
      parsed
      |> Enum.map(&(&1.person_id))
      |> Enum.uniq
      |> Enum.reject(&is_nil/1)

    assert people_ids == [mikeal.id, alex.id, rachel.id]

    titles =
      parsed
      |> Enum.map(&(&1.title))
      |> Enum.uniq

    assert titles == ["Mikeal Rogers", "Alex Sexton", "Rachel White", "Break"]
  end
end
