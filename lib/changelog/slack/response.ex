defmodule Changelog.Slack.Response do
  @derive Jason.Encoder
  defstruct response_type: "in_channel", text: ""
end
