defmodule Changelog.Hashid do
  def encode(ids) when is_list(ids), do: Hashids.encode(hashid(), ids)
  def encode(id), do: Hashids.encode(hashid(), [id])

  def decode(encoded) do
    case Hashids.decode(hashid(), encoded) do
      {:ok, decoded} -> List.first(decoded)
      {:error, _} -> -1
    end
  end

  defp hashid do
    Hashids.new(salt: "long live the developer")
  end
end
