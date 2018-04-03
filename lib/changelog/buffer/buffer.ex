defmodule Changelog.Buffer do
  alias Changelog.NewsItem
  alias Changelog.Buffer.{Client, Content}

  @errbody     ~w(506b005149bbd8223400006b 5226807fe2965a1f3100001c)
  @changelog   ~w(4f3ad7c8512f7ef962000004)
  @jsparty     ~w(5734d7fc1b14578733224a70)
  @gotime      ~w(5734d7fc1b14578733224a70)
  @practicalai ~w(5ac3c64b3fda312b116ca788)

  def queue(item = %NewsItem{type: :audio, object_id: id}) when is_binary(id) do
    link = Content.episode_link(item)
    text = Content.episode_text(item)

    profiles = cond do
      String.starts_with?(id, "gotime") -> @gotime
      String.starts_with?(id, "jsparty") -> @jsparty
      String.starts_with?(id, "practicalai") -> @practicalai
      true -> @changelog
    end

    Client.create((profiles ++ @errbody), text, [link: link])
  end
  def queue(%NewsItem{type: :audio}), do: false
  def queue(item = %NewsItem{object_id: id}) when is_binary(id) do
    link = Content.post_link(item)
    text = Content.post_text(item)
    Client.create(@changelog, text, [link: link])
  end
  def queue(item = %NewsItem{}) do
    image = Content.news_item_image(item)
    link = Content.news_item_link(item)
    text = Content.news_item_text(item)
    Client.create(@changelog, text, [link: link, photo: image])
  end
end
