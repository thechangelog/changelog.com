defmodule Changelog.SponsorView do
  use Changelog.Web, :view

  def logo_url(sponsor, type, version) do
    {module, file} = case type do
      :color_logo -> {Changelog.ColorLogo, sponsor.color_logo}
      :dark_logo  -> {Changelog.DarkLogo, sponsor.dark_logo}
      :light_logo -> {Changelog.LightLogo, sponsor.light_logo}
    end

    module.url({file, sponsor}, version)
    |> String.replace_leading("priv", "")
  end
end
