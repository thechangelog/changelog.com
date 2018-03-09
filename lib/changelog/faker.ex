defmodule Changelog.Faker do
  alias Changelog.Hashid

  def name, do: Enum.random(names())

  def names do
    [
      "Place Holder",
      "Temp Orary",
      "Plz FixMe",
      "TO DO",
      "E Leet",
      "Hax Or",
      "Anony Mous",
      "Wont Fix",
      "Request Puller",
      "NP Incomplete",
      "Crypt Ography",
      "Ima Dev",
      "Wemade Oneup"
    ]
  end

  def handle(name) do
    name = name |> String.downcase |> String.replace(" ", "-")
    salt = Timex.now |> DateTime.to_unix |> Kernel.+(random_number()) |> Hashid.encode
    "#{name}-#{salt}"
  end

  defp random_number(between \\ 1..10000) do
    Enum.random(between)
  end
end
