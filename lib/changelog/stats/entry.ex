defmodule Changelog.Stats.Entry do
  defstruct [
    :ip,
    :episode,
    :bytes,
    :status,
    :agent,
    :latitude,
    :longitude,
    :city_name,
    :continent_code,
    :country_code,
    :country_name
  ]

  @type t :: %Changelog.Stats.Entry{
          ip: String.t(),
          episode: String.t(),
          bytes: non_neg_integer,
          status: non_neg_integer,
          agent: String.t(),
          latitude: float,
          longitude: float,
          city_name: String.t(),
          continent_code: String.t(),
          country_code: String.t(),
          country_name: String.t()
        }
end
