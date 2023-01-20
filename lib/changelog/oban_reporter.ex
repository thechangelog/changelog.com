defmodule Changelog.ObanReporter do
  @moduledoc false

  def attach do
    :telemetry.attach(
      "oban-errors",
      [:oban, :job, :exception],
      &handle_event/4,
      []
    )
  end

  def handle_event([:oban, :job, _], measure, meta, _) do
    extra =
      meta.job
      |> Map.take([:id, :args, :meta, :queue, :worker, :attempt, :max_attempts])
      |> Map.merge(measure)

    Sentry.capture_exception(meta.error, stacktrace: meta.stacktrace, extra: extra)
  end

  def handle_event(_event, _measure, _meta, _opts), do: :ok
end
