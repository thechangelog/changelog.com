defmodule Changelog.Buffer do
  alias Changelog.NewsItem
  alias Changelog.Buffer.{Client, Content}

  @changelog ~w(4f3ad7c8512f7ef962000004 506b005149bbd8223400006b 5226807fe2965a1f3100001c)
  @jsparty   ~w(5734d7fc1b14578733224a70 506b005149bbd8223400006b 5226807fe2965a1f3100001c)
  @gotime    ~w(5734d7fc1b14578733224a70 506b005149bbd8223400006b 5226807fe2965a1f3100001c)

  def queue(item = %NewsItem{type: :audio, object_id: id}) when is_binary(id) do
    text = Content.episode_text(item)
    link = Content.episode_link(item)

    profiles = cond do
      String.starts_with?(id, "gotime") -> @gotime
      String.starts_with?(id, "jsparty") -> @jsparty
      String.starts_with?(id, "podcast") -> @changelog
      String.starts_with?(id, "rfc") -> @changelog
      true -> []
    end

    Client.create(profiles, text, [link: link])
  end
  def queue(%NewsItem{type: :audio}), do: false
  def queue(item = %NewsItem{}) do
    text = Content.news_item_text(item)
    link = Content.news_item_link(item)
    image = Content.news_item_image(item)
    Client.create(@changelog, text, [link: link, photo: image])
  end
end
