defmodule Changelog.Captcha do
  alias Changelog.HTTP

  def host, do: "https://challenges.cloudflare.com/turnstile/v0"

  def verify_url, do: host() <> "/siteverify"

  def verify(response) do
    secret = Application.get_env(:changelog, :turnstile_secret_key)

    verify_url()
    |> HTTP.post!({:form, [{:secret, secret}, {:response, response}]})
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("success", false)
  end
end
