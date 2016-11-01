defmodule Mix.Tasks.Changelog.Stats do
  use Mix.Task

  alias Timex.Duration

  @shortdoc "Processes stats for given date, or yesterday"

  def run(args) when is_nil(args), do: run([])
  def run(args) do
    Mix.Task.run "app.start"

    date = case Timex.parse(List.first(args), "{YYYY}-{0M}-{D}") do
      {:ok, time} -> Timex.to_date(time)
      {:error, _message} -> Timex.today |> Timex.subtract(Duration.from_days(1))
    end

    Changelog.Stats.process(date)
  end
end
