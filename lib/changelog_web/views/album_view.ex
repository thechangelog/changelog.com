defmodule ChangelogWeb.AlbumView do
  use ChangelogWeb, :public_view

  alias Changelog.StringKit

  def art_url(album, version) do
    "https://cdn.changelog.com/albums/#{album.volume}-#{album.slug}-#{version}.jpg"
  end

  def amazon_music_url(album) do
    if StringKit.present?(album.amazon_id),
      do: "https://music.amazon.com/albums/#{album.amazon_id}"
  end

  def apple_music_url(album) do
    if StringKit.present?(album.apple_id),
      do: "https://music.apple.com/us/album/#{album.slug}/#{album.apple_id}"
  end

  def bandcamp_url(album) do
    if StringKit.present?(album.bandcamp_url),
      do: album.bandcamp_url
  end

  def merch_url(album) do
    "https://merch.changelog.com/products/#{album.slug}"
  end

  def header_art_attrs(album) do
    %{
      src: art_url(album, "full"),
      srcset: "#{art_url(album, "full")} 3000w, #{art_url(album, "512")} 440w",
      sizes: "(min-width:880px) 490w, 440w",
      alt: "#{album.name} Album Artwork"
    }
  end

  def buy_links(album) do
    [
      {"Direct", merch_url(album)},
      {"Bandcamp", bandcamp_url(album)}
    ]
    |> Enum.reject(fn {_name, url} -> is_nil(url) end)
  end

  def listen_links(album) do
    [
      {"Spotify", spotify_url(album)},
      {"Apple Music", apple_music_url(album)},
      {"Amazon Music", amazon_music_url(album)},
      {"YouTube Music", youtube_music_url(album)}
    ]
    |> Enum.reject(fn {_name, url} -> is_nil(url) end)
  end

  def spotify_url(album) do
    if StringKit.present?(album.spotify_id),
      do: "https://open.spotify.com/album/#{album.spotify_id}"
  end

  def spotify_embed_url(album) do
    "https://open.spotify.com/embed/album/#{album.spotify_id}"
  end

  def spotify_embed_height(album) do
    case album.slug do
      "theme-songs" -> 1820
      "next-level" -> 1480
      "dance-party" -> 1280
      "after-party" -> 1520
      _else -> 1024
    end
  end

  def youtube_music_url(album) do
    if StringKit.present?(album.youtube_id),
      do: "https://music.youtube.com/playlist?list=#{album.youtube_id}"
  end
end
