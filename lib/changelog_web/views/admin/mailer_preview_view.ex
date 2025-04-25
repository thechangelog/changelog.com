defmodule ChangelogWeb.Admin.MailerPreviewView do
  use ChangelogWeb, :admin_view

  def email_addresses(email) do
    email.to
    |> Enum.map(fn {_name, address} -> address end)
    |> Enum.join(", ")
  end

  def format_email_address(address) when is_binary(address), do: address
  def format_email_address({nil, address}), do: address

  def format_email_address({name, address}) do
    "#{name} <#{address}>"
  end

  def iframe_content(email, "text"), do: content_tag(:pre, do: email.text_body)
  def iframe_content(email, _other), do: email.html_body

  def send_to_path(mailer, nil) do
    ~p"/admin/mailers/#{mailer}/send"
  end

  def send_to_path(mailer, extra) do
    ~p"/admin/mailers/#{mailer}/send" <> "?extra=#{extra}"
  end
end
