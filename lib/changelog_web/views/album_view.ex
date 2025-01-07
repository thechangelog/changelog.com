defmodule ChangelogWeb.AlbumView do
  use ChangelogWeb, :public_view

  def art_url(album, version) do
    "https://cdn.changelog.com/albums/#{album.volume}-#{album.slug}-#{version}.jpg"
  end

  def amazon_music_url(album) do
    "https://music.amazon.com/albums/#{album.amazon_id}"
  end

  def apple_music_url(album) do
    "https://music.apple.com/us/album/#{album.slug}/#{album.apple_id}"
  end

  def spotify_url(album) do
    "https://open.spotify.com/album/#{album.spotify_id}"
  end

  def spotify_embed_url(album) do
    "https://open.spotify.com/embed/album/#{album.spotify_id}"
  end

  def youtube_music_url(album) do
    "https://music.youtube.com/playlist?list=#{album.youtube_id}"
  end

  def header_art_attrs(album) do
    %{
      src: art_url(album, "full"),
      srcset: "#{art_url(album, "full")} 3000w, #{art_url(album, "512")} 440w",
      sizes: "(min-width:880px) 490w, 440w",
      alt: "#{album.name} Album Artwork"
    }
  end
end
