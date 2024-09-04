defmodule Changelog.Stats.S3 do
  def config do
    [
      access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
      secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
      host: System.get_env("AWS_API_HOST")
    ]
  end

  def get_logs(slug, prefix) do
    bucket = "changelog-logs-#{slug}"

    list_logs(bucket, prefix)
    |> Task.async_stream(fn %{key: key} -> get_log(bucket, key) end)
    |> Enum.map(fn {:ok, log} -> log end)
  end

  defp get_log(bucket, key) do
    ExAws.S3.get_object(bucket, key)
    |> ExAws.request!(config())
    |> Map.get(:body)
  end

  def download_logs(slug, prefix, filename) do
    {:ok, file} = File.open(filename, [:write])
    logs = get_logs(slug, prefix)
    Enum.each(logs, &(IO.write(file, &1 <> "\n")))
    File.close(file)
  end

  @doc """
  returns a list of log object data for a given bucket and prefix, continuing
  past the S3's 1000 key limit when necessary
  """
  def list_logs(bucket, prefix, next \\ nil, accumulated \\ []) do
    options = if next, do: [prefix: prefix, continuation_token: next], else: [prefix: prefix]
    request = ExAws.S3.list_objects_v2(bucket, options)

    case ExAws.request!(request, config()) do
      %{body: %{is_truncated: "false", contents: contents}} ->
        accumulated ++ contents
      %{body: %{next_continuation_token: next, contents: contents}} ->
        list_logs(bucket, prefix, next, accumulated ++ contents)
    end
  end
end
