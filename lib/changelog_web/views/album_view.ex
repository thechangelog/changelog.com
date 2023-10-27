defmodule ChangelogWeb.AlbumView do
  use ChangelogWeb, :public_view

  def art_url(album, version) do
    "https://cdn.changelog.com/albums/#{album.volume}-#{album.slug}-#{version}.jpg"
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
end
