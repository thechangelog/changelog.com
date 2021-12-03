defmodule Mix.Tasks.Changelog.Static.Upload do
  use Mix.Task

  @shortdoc "Uploads latest priv/static files to S3"

  def run(_) do
    Mix.Task.run("app.start")
    Changelog.S3Static.upload_static_files_to_s3()
  end
end
