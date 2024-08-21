defmodule Changelog.EmailCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      Swoosh.TestAssertions

      # we special-case this function because for some reason Swoosh's email == email regex
      # fails even though each individual attribute of said email matches...
      defp assert_email_sent(email) do
        Swoosh.TestAssertions.assert_email_sent to: email.to, from: email.from, subject: email.subject, html_body: email.html_body
      end

      defp assert_email_not_sent(email) do
        Swoosh.TestAssertions.assert_email_not_sent(email)
      end

      defp assert_no_email_sent do
        Swoosh.TestAssertions.assert_no_email_sent()
      end
    end
  end
end
