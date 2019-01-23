defmodule ChangelogWeb.Admin.MailerPreviewView do
  use ChangelogWeb, :admin_view

  def email_addresses(email) do
    email
    |> Bamboo.Mailer.normalize_addresses()
    |> Bamboo.Email.all_recipients()
    |> Enum.map(&Bamboo.Email.get_address/1)
    |> Enum.join(", ")
  end

  def format_email_address(address) when is_binary(address), do: address
  def format_email_address({nil, address}), do: address
  def format_email_address({name, address}) do
    "#{name} <#{address}>"
  end

  def reply_to(%{headers: %{"Reply-To" => to}}) when is_binary(to), do: to
  def reply_to(_else), do: nil
end
