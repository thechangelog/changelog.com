defmodule DockerSecret do
  def get(secret) do
    path = "/run/secrets/#{secret}"
    case File.read(path) do
      {:ok, value} ->
        IO.puts("#{secret} read from #{path}")
        String.trim(value)
      _ ->
        IO.puts("#{secret} read from environment")
        System.get_env(secret)
    end
  end
end
