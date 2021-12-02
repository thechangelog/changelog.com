defmodule Mix.Tasks.Changelog.Static.Upload do
  use Mix.Task

  @shortdoc "Uploads latest priv/static files to S3"

  def run(_) do
    Mix.Task.run("app.start")
    Changelog.S3Static.upload_static_files_to_s3()
  end

  # def upload_local_files_to_s3(bucket, source, destination) do
  # 	source
  # 	|> local_files_to_upload()
  # 	|> Enum.each(&(put_file(bucket, destination, &1)))
  # end

  # def local_files_to_upload(static_path) do
  # 	static_path
  # 	|> Path.join("cache_manifest.json")
  #    |> File.read!()
  #    |> Phoenix.json_library().decode!()
  #    |> Map.get("latest")
  # 	|> Map.values()
  # 	|> Enum.map(&(%{relative: &1, absolute: Path.join(static_path, &1)}))
  # end

  # defp put_file(bucket, prefix, file) do
  # 	if s3_file_exists?(bucket, prefix, file) do
  # 		Logger.info "Skipping #{file.relative}"
  # 	else
  #    	Logger.info "Uploading #{file.relative}"
  #    	key = Path.join(prefix, file.relative)
  #    	data = File.read!(file.absolute)
  #    	ExAws.request(ExAws.S3.put_object(bucket, key, data))
  # 	end
  #  end

  # defp s3_file_exists?(bucket, prefix, file) when is_map(file), do: s3_file_exists?(bucket, prefix, file.relative)

  # defp s3_file_exists?(bucket, prefix, file) do
  # 	key = Path.join(prefix, file)

  # 	case ExAws.request(ExAws.S3.head_object(bucket, key)) do
  # 		{:ok, %{status_code: 200}} -> true
  # 		{:error, _} -> false
  # 	end
  # end
end
