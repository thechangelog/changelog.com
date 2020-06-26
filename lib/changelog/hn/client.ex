defmodule Changelog.HN.Client do
  use HTTPoison.Base

  require Logger

  def process_url(url), do: "https://news.ycombinator.com/#{url}"

  def submit(title, url) do
    username = Application.get_env(:changelog, :hn_user)
    password = Application.get_env(:changelog, :hn_password)
    cookie = auth(username, password)
    submit(title, url, cookie)
  end

  defp submit(_title, _url, nil) do
    log("auth fail")
  end

  defp submit(title, url, cookie) do
    %{body: body} = get!("submit", [], hackney: [cookie: [cookie]])

    case Regex.run(~r/<input type="hidden" name="fnid" value="([^\"]+)">/, body) do
      [_, fnid] -> submit(title, url, cookie, fnid)
      _else -> log("fnid fail")
    end
  end

  defp submit(title, url, cookie, fnid) do
    body = {:form, [{"title", title}, {"url", url}, {"fnid", fnid}]}
    post!("r", body, [], hackney: [cookie: [cookie]])
  end

  defp auth(username, password) do
    %{headers: headers} = post!("submit", {:form, [{"acct", username}, {"pw", password}]})

    headers
    |> Enum.find(
      # default for no cookie will result in `nil` at end of pipeline
      {"", ""},
      fn {key, _} -> String.match?(key, ~r/\Aset-cookie\z/i) end
    )
    |> elem(1)
    |> String.split(";")
    |> Changelog.ListKit.compact()
    |> List.first()
  end

  defp log(message) do
    Logger.info(fn -> "API Error (HN): #{message}" end)
    message
  end
end
