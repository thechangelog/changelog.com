defmodule Changelog.Timex do
  def from_ecto(datetime = %Timex.DateTime{}), do: datetime
  def from_ecto(datetime) do
    datetime |> Ecto.DateTime.to_erl |> Timex.DateTime.from_erl
  end

  def to_ecto(datetime = %Ecto.DateTime{}), do: datetime
  def to_ecto(datetime) do
    datetime |> Timex.Convertable.to_erlang_datetime |> Ecto.DateTime.from_erl
  end
end
