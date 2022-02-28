defmodule Changelog.Metacasts.Filterer.Parser do
  require Logger
  alias Changelog.Metacasts.Filterer.{Representation, FacetStatement, Statements}

  @facets %{
    "podcast" => {:podcast, :slugs},
    "topic" => {:topic, :slugs},
    "guest" => {:guest, :strings},
    "host" => {:host, :strings}
  }

  @list_closers ["or", "and"]
  @sub_facet_logics ["any", "all"]

  def parse(filter_string) do
    representation =
      filter_string
      |> loosen_tight_parens()
      |> normalize_whitespace()
      |> String.trim()
      |> String.graphemes()
      |> tokenize()
      |> parse_tokens()

    errors = Enum.filter(representation.statements, &match?({:error, _}, &1))

    cond do
      Enum.any?(errors) -> {:error, errors}
      is_nil(representation.start) -> {:error, :no_start}
      true -> {:ok, representation}
    end
  end

  def tokenize(graphemes) do
    {last_token, tokens, _} =
      Enum.reduce(graphemes, {"", [], nil}, fn grapheme, {current_token, tokens, meta} ->
        case {current_token, grapheme, meta} do
          # Continuing string over space
          {_, " ", :keep_space} -> {current_token <> grapheme, tokens, :keep_space}
          # Closing string
          {_, "\"", :keep_space} -> {"", [current_token | tokens], nil}
          # Closing token on space
          {_, " ", _} -> {"", [current_token | tokens], nil}
          # Opening string, setting space behavior
          {"", "\"" <> string_start, nil} -> {string_start, tokens, :keep_space}
          # Default, add grapheme to token
          {_, grapheme, _} -> {current_token <> grapheme, tokens, meta}
        end
      end)

    Enum.reverse([:end | [last_token | tokens]])
    |> Enum.reject(fn token ->
      token == ""
    end)
  end

  def parse_tokens(tokens) do
    {_, %{statements: statements} = repr} =
      Enum.reduce(tokens, {nil, %Representation{}}, fn token, {current, repr} ->
        {current, repr} = parse_token(token, current, repr)
        {current, repr}
      end)

    %{repr | statements: Enum.reverse(statements)}
  end

  defp parse_token("only", nil, repr = %{start: nil}) do
    {nil, %{repr | start: :only}}
  end

  defp parse_token("except", nil, repr = %{start: nil}) do
    {nil, %{repr | start: :except}}
  end

  # Capture facet filter contents as a list of values
  # Examples:
  # podcast: gotime, rfc or afk
  # guest: "Jason Fried" or "Steve Jobs"
  # topic: svelte
  defp parse_token(token, current = %FacetStatement{mode: :open, items: items}, repr) do
    current =
      cond do
        # Capture member of list, with comma
        String.ends_with?(token, ",") ->
          token = String.trim_trailing(token, ",")
          %{current | items: [token | items]}

        # Add single item or possibly two-item list
        Enum.empty?(items) ->
          %{current | mode: :single, items: [token | items]}

        # Add item without trailing comma, requires closer
        true ->
          %{current | mode: :closable, items: [token | items]}
      end

    parsed(repr, current)
  end

  defp parse_token(token, current = %FacetStatement{mode: :single, items: items}, repr) do
    cond do
      # Capture closer for list, such as "or", okay if a single item
      length(items) == 1 and token in @list_closers ->
        parsed(repr, %{current | mode: :closing, logic: list_closer(token)})

      # No closer found to turn single into two-item list, closing and reparsing token
      true ->
        # Update representation
        repr = add_statement(repr, %{current | mode: :closed, logic: :and})
        # Re-run token parsing so this doesn't swallow the token entirely
        parse_token(token, nil, repr)
    end
  end

  defp parse_token(token, current = %FacetStatement{mode: :closable, items: items}, repr) do
    current =
      cond do
        # Capture closer for list, such as "or", okay if a single item without comma or list of commad items
        length(items) > 0 and token in @list_closers ->
          %{current | mode: :closing, logic: list_closer(token)}

        # No closer found to turn single into two-item list, closing
        true ->
          {:error,
           "Unexpected value '#{token}' while building list, mode: #{current.mode}, facet: #{current.repr}, type: #{current.type}: #{inspect(items)}"}
      end

    case current do
      %FacetStatement{} ->
        parsed(repr, current)

      {:error, _} ->
        repr
        |> add_statement(current)
        |> parsed(nil)
    end
  end

  defp parse_token(token, current = %FacetStatement{mode: :closing, items: items}, repr) do
    # Add final item to closing list
    current = %{current | mode: :closed, items: Enum.reverse([token | items])}

    repr
    |> add_statement(current)
    |> parsed(nil)
  end

  defp parse_token(token, current = %FacetStatement{}, repr) do
    repr
    |> add_statement(
      {:error,
       "Unexpected value '#{token}' while building list, mode: #{current.mode}, facet: #{current.repr}, type: #{current.type}: #{inspect(current.items)}"}
    )
    |> parsed(nil)
  end

  defp parse_token(
         token = "unless",
         nil,
         repr = %{statements: [%FacetStatement{mode: :closed} | _]}
       ) do
    repr
    |> add_statement(Statements.sub_facet_start(token))
    |> parsed(nil)
  end

  defp parse_token(token = "if", nil, repr = %{statements: [%FacetStatement{mode: :closed} | _]}) do
    repr
    |> add_statement(Statements.sub_facet_start(token))
    |> parsed(nil)
  end

  # This macro generates functions that look like:
  # def parse_token("podcast:", current, repr) do
  #   parse_facet_token("podcast", current, repr)
  # end
  Enum.each(@facets, fn {facet, _type} ->
    match = facet <> ":"

    Module.eval_quoted(
      __MODULE__,
      quote do
        defp parse_token(unquote(match), current, repr) do
          parse_facet_token(unquote(facet), current, repr)
        end
      end
    )
  end)

  defp parse_token("unless", _, repr) do
    repr
    |> add_statement({:error, "Unexpected unless, should follow on a facet filter."})
    |> parsed(nil)
  end

  defp parse_token("if", _, repr) do
    repr
    |> add_statement({:error, "Unexpected if, should follow on a facet filter."})
    |> parsed(nil)
  end

  defp parse_token(token, nil, repr = %{statements: [{:sub_facet_start, _} | _]})
       when token in @sub_facet_logics do
    repr
    |> add_statement(Statements.sub_facet_logic(token))
    |> parsed(nil)
  end

  defp parse_token("(", nil, repr = %{statements: [{:sub_facet_logic, _} | _]}),
    do: parsed(repr, nil)

  defp parse_token("(", current, repr) do
    repr
    |> add_statement(
      {:error,
       "Unexpected '(' not after sub facet logic marker, should follow 'unless any', 'if any', 'unless all' or 'if all'."}
    )
    |> parsed(current)
  end

  defp parse_token(")", nil, repr) do
    repr
    |> add_statement(Statements.sub_facet_end())
    |> parsed(nil)
  end

  defp parse_token(:end, _, repr) do
    {nil, repr}
  end

  defp parse_token(token, current, repr) do
    Logger.info("not implemented: #{token}")
    parsed(repr, current)
  end

  defp parse_facet_token(facet, _current, repr) do
    {facet_repr, facet_type} = @facets[facet]
    current = %FacetStatement{repr: facet_repr, type: facet_type, mode: :open}
    parsed(repr, current)
  end

  defp add_statement(repr = %{statements: statements}, statement) do
    %{repr | statements: [statement | statements]}
  end

  defp parsed(repr, new_current), do: {new_current, repr}

  defp loosen_tight_parens(binary) do
    binary
    |> String.replace("(", " ( ")
    |> String.replace(")", " ) ")
  end

  defp normalize_whitespace(binary) do
    # All whitespace will be spaces and only single spaces
    # This assumes this is okay for our strings which it probably is
    binary
    |> String.replace(~r/\s+/, " ")
  end

  defp list_closer("or"), do: :or
  defp list_closer("and"), do: :and
end
