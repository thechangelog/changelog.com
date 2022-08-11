defmodule Changelog.File do
  defmacro __using__(types) do
    quote do
      use Waffle.Definition
      use Waffle.Ecto.Definition

      @acl :public_read

      # We can purge subsets of files from the CDN by setting a key on upload.
      # The module name that uses this module seems to be the best way of
      # categorizing sets of files we might want to purge together.
      # e.g. - purge all 'audio' files, purge all 'avatars', etc
      def cdn_key do
        __MODULE__
        |> to_string()
        |> String.split(".")
        |> List.last()
        |> String.downcase()
      end

      def default_url(_version, _scope) do
        ChangelogWeb.Router.Helpers.static_url(ChangelogWeb.Endpoint, "/images/defaults/black.png")
      end

      def s3_object_headers(version, {file, scope}) do
        [
          content_type: mime_type(file),
          meta: [
            {"surrogate-control", Application.get_env(:changelog, :cdn_cache_control_s3)},
            {"surrogate-key", cdn_key()}
          ]
        ]
      end

      def validate({file, _}) do
        Enum.member?(unquote(types), file_type(file))
      end

      def file_type(file), do: Changelog.FileKit.get_type(file)

      def mime_type(file), do: Changelog.FileKit.mime_type(file)

      # Takes a list of strings and returns a joined string for passing to `convert`
      # See https://www.smashingmagazine.com/2015/06/efficient-image-resizing-with-imagemagick/
      def convert_args(opts) when is_binary(opts), do: convert_args([opts])

      def convert_args(opts) when is_list(opts) do
        opts ++ [
          "-strip",
          "-interlace none",
          "-colorspace sRGB",
          "-filter Triangle",
          "-dither None",
          "-posterize 136",
          "-quality 82",
          "-define filter:support=2",
          "-define jpeg:fancy-upsampling=off",
          "-define png:compression-filter=5",
          "-define png:compression-level=9",
          "-define png:compression-strateg1",
          "-define png:exclude-chunk=all"
        ] |> Enum.join(" ")
      end

      defp hashed(id), do: Changelog.Hashid.encode(id)
      defp source(scope), do: scope.__meta__.source
    end
  end
end
