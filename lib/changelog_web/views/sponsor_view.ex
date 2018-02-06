defmodule ChangelogWeb.SponsorView do
  use ChangelogWeb, :public_view

  alias Changelog.Files.{Avatar, ColorLogo, DarkLogo, LightLogo}
  alias ChangelogWeb.Endpoint

  def avatar_path(sponsor, version) do
    {sponsor.avatar, sponsor}
    |> Avatar.url(version)
    |> String.replace_leading("/priv", "")
  end

  def avatar_url(sponsor), do: avatar_url(sponsor, :small)
  def avatar_url(sponsor, version) do
    static_url(Endpoint, avatar_path(sponsor, version))
  end

  def logo_url(sponsor, type, version) do
    {module, file} = case type do
      :color_logo -> {ColorLogo, sponsor.color_logo}
      :dark_logo  -> {DarkLogo, sponsor.dark_logo}
      :light_logo -> {LightLogo, sponsor.light_logo}
    end

    module.url({file, sponsor}, version)
    |> String.replace_leading("/priv", "")
  end
end
