defmodule Changelog.Hashid do
  def encode(ids) when is_list(ids), do: Hashids.encode(hashid(), ids)
  def encode(id), do: Hashids.encode(hashid(), [id])

  def decode(encoded) do
    case Hashids.decode(hashid(), encoded) do
      {:ok, ids} -> ids |> List.first() |> range_check()
      {:error, _} -> -1
    end
  end

  defp hashid, do: Hashids.new(salt: "long live the developer")

  defp range_check(number) do
    if Enum.member?(-2_147_483_648..2_147_483_648, number), do: number, else: -1
  end
end
