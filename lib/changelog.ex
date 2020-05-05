defmodule Changelog do
  require IEx

  def pry, do: IEx.pry()

  def pry(arg) do
    pry()
    arg
  end
end
