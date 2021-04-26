defmodule Changelog.Captcha do
  def host, do: "https://www.google.com/recaptcha/api"

  def verify_url, do: host() <> "/siteverify"

  def verify(response) do
    secret = Application.get_env(:changelog, :recaptcha_secret_key)

    verify_url()
    |> HTTPoison.post!({:form, [{:secret, secret}, {:response, response}]})
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("success", false)
  end
end
