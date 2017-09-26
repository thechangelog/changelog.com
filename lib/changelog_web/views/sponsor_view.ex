defmodule ChangelogWeb.SponsorView do
  use ChangelogWeb, :public_view

  alias Changelog.Files.{ColorLogo, DarkLogo, LightLogo}

  def logo_url(sponsor, type, version) do
    {module, file} = case type do
      :color_logo -> {ColorLogo, sponsor.color_logo}
      :dark_logo  -> {DarkLogo, sponsor.dark_logo}
      :light_logo -> {LightLogo, sponsor.light_logo}
    end

    module.url({file, sponsor}, version)
    |> String.replace_leading("/priv", "/")
    |> String.replace(~r{^//}, "/") # Arc 0.6 now prepends / to *all* URLs
  end
end
