defmodule App.WelcomeEmail do
  use Bamboo.Phoenix, view: App.EmailView

  require EEx

  def welcome_text_email(email_address) do
    new_email
    |> to(email_address)
    |> from("us@example.com")
    |> subject("Welcome!")
    |> text_body("Welcome to MyApp!")
  end

  def welcome_html_email(email_address) do
    email_address
    |> welcome_text_email()
    |> html_body(welcome_html)
  end

  defp welcome_html() do
    EEx.eval_file(
      "lib/web/templates/layout/mailer.html.eex",
      body: EEx.eval_file("lib/web/templates/email/welcome.html.eex")
    )
  end
end
