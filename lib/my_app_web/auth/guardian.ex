defmodule MyAppWeb.Guardian do
  use Guardian, otp_app: :my_app

  def subject_for_token(user, _claims) do
    sub = MyApp.Auth.generate_auth_token(user)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    token = claims["sub"]
    resource = MyApp.Auth.get_user_by_token(token)
    {:ok,  resource}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
