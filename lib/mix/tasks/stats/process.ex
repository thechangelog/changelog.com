defmodule Mix.Tasks.Changelog.Stats.Process do
  use Mix.Task

  @shortdoc "Processes stats for given date, or all missing dates"

  def run(args) when is_nil(args), do: run([])

  def run(args) do
    Mix.Task.run("app.start")

    case Timex.parse(List.first(args), "{YYYY}-{0M}-{D}") do
      {:ok, time} -> Changelog.Stats.process(Timex.to_date(time))
      {:error, _message} -> Changelog.Stats.process()
    end
  end
end
