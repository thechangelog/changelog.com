defmodule Changelog.Buffer do
  alias Changelog.NewsItem
  alias Changelog.Buffer.{Client, Content}

  @profiles ["4f3ad7c8512f7ef962000004", "506b005149bbd8223400006b"]

  def queue(%NewsItem{type: :audio}), do: false
  def queue(item = %NewsItem{}) do
    text = Content.news_item_text(item)
    link = Content.news_item_link(item)
    image = Content.news_item_image(item)
    Client.create(@profiles, text, [link: link, photo: image])
  end
end
