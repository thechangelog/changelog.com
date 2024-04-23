defmodule Changelog.Vitals do
  def elixir_version do
    System.version()
  end

  def erlang_version do
    :erlang.system_info(:otp_release)
  end

  def postgres_version do
    query = "SELECT setting FROM pg_settings WHERE name = 'server_version';"

    case Changelog.Repo.query(query) do
      {:ok, result} ->
        result
        |> Map.get(:rows, [])
        |> List.first()

      _else ->
        "Unknown"
    end
  end
end
