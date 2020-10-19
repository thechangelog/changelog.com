defmodule Changelog.Metacasts.Filterer.Generator do
  alias Changelog.Metacasts.Filterer.{FacetStatement, FiltererError}

  require Logger

  def generate_stream_filters(%{start: :except, statements: statements}) do
    filters = generate_filters(statements)

    fn items ->
      Stream.reject(items, &any_filter(filters, &1))
    end
  end

  def generate_stream_filters(%{start: :only, statements: statements}) do
    filters = generate_filters(statements)

    fn items ->
      Stream.filter(items, &any_filter(filters, &1))
    end
  end

  defp any_filter(filters, item) do
    Enum.any?(filters, fn filter ->
      filter.(item)
    end)
  end

  defp all_filter(filters, item) do
    Enum.all?(filters, fn filter ->
      filter.(item)
    end)
  end

  defp generate_filters(statements) do
    generate_filters(statements, [])
  end

  defp generate_filters([], filters) do
    Enum.reverse(filters)
  end

  defp generate_filters([statement | statements], filters) do
    {filter, statements} = generate_filter(statement, statements)
    generate_filters(statements, [filter | filters])
  end

  # Final statement is FacetStatement, no sub_facet
  defp generate_filter(%FacetStatement{repr: repr, logic: logic, items: items}, [] = statements) do
    facet_filter = generate_facet_filter(repr, logic, items)

    {fn item ->
       facet_filter.(item)
     end, statements}
  end

  defp generate_filter(
         %FacetStatement{repr: repr, logic: logic, items: items},
         [look_ahead | ahead_statements] = statements
       ) do
    sub_facet? = has_sub_facet?(look_ahead)
    facet_filter = generate_facet_filter(repr, logic, items)

    if sub_facet? do
      {sub_facet_filter, statements} = generate_sub_facet_filter(look_ahead, ahead_statements)

      {fn item ->
         facet_filter.(item) and sub_facet_filter.(item)
       end, statements}
    else
      {fn item ->
         facet_filter.(item)
       end, statements}
    end
  end

  defp generate_filter(statement, _) do
    Logger.error(
      "An unrecognized statement was encountered, filter generation failed: #{inspect(statement)}"
    )

    raise FiltererError, {:bad_statement, statement}
  end

  defp generate_facet_filter(repr, logic, items) do
    case logic do
      :or ->
        fn item ->
          item_has_option?(item, repr, items)
        end

      :and ->
        fn item ->
          item_has_requirements?(item, repr, items)
        end
    end
  end

  defp generate_sub_facet_filter({:sub_facet_start, type}, [
         {:sub_facet_logic, logic} | statements
       ]) do
    {sub_statements, statements, depth} =
      Enum.reduce(statements, {[], [], 1}, fn statement, {sub, rem, depth} ->
        {sub, rem} =
          if depth > 0 do
            {[statement | sub], rem}
          else
            {sub, [statement | rem]}
          end

        depth =
          case statement do
            {:sub_facet_start, _} -> depth + 1
            :sub_facet_end -> depth - 1
            _ -> depth
          end

        {sub, rem, depth}
      end)

    [_stripped_end | sub_statements] = sub_statements
    sub_statements = Enum.reverse(sub_statements)
    statements = Enum.reverse(statements)

    if depth > 0 do
      raise FiltererError,
            {:bad_nesting, "Bad nesting encountered, ended sub-faceting with depth > 1"}
    end

    sub_filters = generate_filters(sub_statements)

    {invert?, enumerator_function} =
      case {type, logic} do
        {:unless, :or} -> {true, &any_filter/2}
        {:unless, :and} -> {true, &all_filter/2}
        {:if, :or} -> {false, &any_filter/2}
        {:if, :and} -> {false, &all_filter/2}
      end

    filter_function =
      if invert? do
        fn item ->
          not enumerator_function.(sub_filters, item)
        end
      else
        fn item ->
          enumerator_function.(sub_filters, item)
        end
      end

    {filter_function, statements}
  end

  defp item_has_option?(item, repr, options) do
    case Map.get(item, repr, nil) do
      nil ->
        Logger.warn("Item being filtered missing attribute: #{repr}")
        false

      item_attr when is_list(item_attr) ->
        Enum.any?(item_attr, fn attr ->
          Enum.any?(options, fn option ->
            attr == option
          end)
        end)

      item_attr when is_binary(item_attr) ->
        Enum.any?(options, fn option ->
          item_attr == option
        end)

      _ ->
        Logger.error("Item being filtered has a bad type for attribute: #{repr}")
        false
    end
  end

  defp item_has_requirements?(item, repr, requirements) do
    case Map.get(item, repr, nil) do
      nil ->
        Logger.warn("Item being filtered missing attribute: #{repr}")
        false

      item_attr when is_list(item_attr) ->
        Enum.all?(requirements, fn req ->
          Enum.any?(item_attr, fn attr ->
            attr == req
          end)
        end)

      item_attr when is_binary(item_attr) ->
        Enum.all?(requirements, fn req ->
          item_attr == req
        end)

      _ ->
        Logger.error("Item being filtered has a bad type for attribute: #{repr}")
        false
    end
  end

  defp has_sub_facet?({:sub_facet_start, _}), do: true
  defp has_sub_facet?(_), do: false
end
