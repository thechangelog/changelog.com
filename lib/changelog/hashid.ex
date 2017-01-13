defmodule Changelog.Hashid do
  def encode(ids) when is_list(ids), do: Hashids.encode(hashid(), ids)
  def encode(id), do: Hashids.encode(hashid, [id])

  def decode(encoded) do
    decoded = Hashids.decode! hashid, encoded

    if length(decoded) > 1 do
      decoded
    else
      List.first(decoded)
    end
  end

  defp hashid do
    Hashids.new salt: "long live the developer"
  end
end
