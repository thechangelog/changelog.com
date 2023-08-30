# from https://gist.github.com/andreaseriksson/e454b9244a734310d4ab74d8595f98cd
# via https://fly.io/phoenix-files/migrating-to-verified-routes
defmodule Mix.Tasks.ConvertToVerifiedRoutes do
  @shortdoc "Fix routes"

  use Mix.Task

  @regex ~r/(Routes\.)(.*)_(path|url)\(.*?\)/
  @web_module ChangelogWeb

  def run(_) do
    Path.wildcard("lib/**/*.*ex")
    |> Enum.concat(Path.wildcard("test/**/*.*ex*"))
    |> Enum.sort()
    |> Enum.filter(&(File.read!(&1) |> String.contains?("Routes.")))
    |> Enum.reduce(%{}, fn filename, learnings ->
      test_filename(filename, learnings)
    end)

    :ok
  end

  def test_filename(filename, learnings) do
    Mix.shell().info(filename)

    content = File.read!(filename)

    case replace_content(content, learnings) do
      {:ok, content, learnings} ->
        File.write!(filename, content)
        learnings
      _ ->
        learnings
    end
  end

  def replace_content(content, learnings) do
    case Regex.run(@regex, content) do
      [route|_] -> ask_about_replacement(content, route, learnings)
      _ -> {:ok, content, learnings}
    end
  end

  def ask_about_replacement(content, route, learnings) do
    route = String.trim(route)

    if verified_route = find_verified_route_from_string(route) do
      replacement = Map.get(learnings, route) || ask_for_direct_match(route, verified_route) || ask_for_fallback(route, verified_route)

      if replacement && (String.starts_with?(replacement, "~p\"/") || String.starts_with?(replacement, "url")) do
        replace_content(
          String.replace(content, route, replacement),
          Map.put(learnings, route, replacement)
        )
      end
    else
      {:ok, content, learnings}
    end
  end

  def ask_for_fallback(route, _verified_route) do
    response = Mix.shell().prompt(
      """
      What is the verified route for (type "skip" for skipping):
        #{IO.ANSI.red}#{route}#{IO.ANSI.reset}
      Start with:
        ~p"/..
      """)
    response = String.trim("#{response}")
    response != "" && response
  end

  def ask_for_direct_match(route, verified_route) do
    if Mix.shell().yes?(
      """
      Should we replace
        #{IO.ANSI.red}#{route}#{IO.ANSI.reset}
      with
        #{IO.ANSI.green}#{verified_route}#{IO.ANSI.reset}
      """) do
      verified_route
    end
  end

  def find_verified_route_from_string(route) do
    parts =
      route
      |> String.replace("Routes.", "")
      |> String.split("(")

    with [route_helper, arguments|_] <- parts do
      arguments =
        arguments
        |> String.replace_trailing(")", "")
        |> String.split(",")
        |> Enum.map(&String.trim/1)

      try do
      @web_module.Router.__routes__()
      |> Enum.find(fn %{helper: helper, plug_opts: plug_opts} ->
        is_atom(plug_opts) &&
          Enum.member?(arguments, ":#{plug_opts}") &&
          String.starts_with?(route_helper, helper)
      end)
      |> case do
        %{path: "" <> path} ->
          path = interpolate_path_with_vars(path, arguments)
          path = maybe_add_params(path, arguments)

          if String.contains?(route_helper, "_url") do
            ~s[url(~p"#{path}")]
          else
            ~s(~p"#{path}")
          end
        _ ->
          nil
      end
      rescue
        ArgumentError -> IO.puts("proflem with #{route}")
        nil
      end
    end
  end

  def interpolate_path_with_vars(path, arguments) do
    arguments = Enum.slice(arguments, 2..10)

    path
    |> String.split("/")
    |> Enum.filter(&String.starts_with?(&1, ":"))
    |> Enum.with_index()
    |> Enum.reduce(path, fn {slot, idx}, memo ->
      argument = Enum.at(arguments, idx)
      argument = "{#{argument}}"
      String.replace(memo, slot, "##{argument}", global: false)
    end)
  end

  def maybe_add_params(path, arguments) do
    case Enum.filter(arguments, &String.contains?(&1, ": ")) do
      [] ->
        if "params" in arguments do
          query_params = "{params}"
          "#{path}?##{query_params}"
        else
          path
        end
      query_params ->
        query_params = "{#{inspect(query_params) |> String.replace("\"", "") }}"
        "#{path}?##{query_params}"
    end
  end
end
