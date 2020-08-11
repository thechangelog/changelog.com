defmodule Changelog.Metacasts.Filterer.Statements do
  alias Changelog.Metacasts.Filterer.FacetStatement
  def sub_facet_start("unless"), do: {:sub_facet_start, :unless}
  def sub_facet_start("if"), do: {:sub_facet_start, :if}

  def sub_facet_logic("any"), do: {:sub_facet_logic, :or}

  def sub_facet_logic("all"), do: {:sub_facet_logic, :and}

  def sub_facet_end, do: :sub_facet_end

  def facet(facet), do: %FacetStatement{repr: facet}
end
