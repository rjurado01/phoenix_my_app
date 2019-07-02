defmodule Web.Guardian do
  use Guardian, otp_app: :my_app

  def subject_for_token(user, _claims) do
    App.Auth.generate_auth_token(user)
  end

  def resource_from_claims(claims) do
    token = claims["sub"]
    resource = App.Auth.get_user_by_token(token)

    if resource do
      {:ok,  resource}
    else
      {:error, :resource_not_found}
    end
  end
end
