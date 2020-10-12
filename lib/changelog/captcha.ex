defmodule Changelog.Captcha do
  def host, do: "https://hcaptcha.com"

  def verify_url, do: host() <> "/siteverify"

  def verify(response) do
    secret = Application.get_env(:changelog, :hcaptcha_secret_key)

    verify_url()
    |> HTTPoison.post!({:form, [{:secret, secret}, {:response, response}]})
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("success", false)
  end
end
