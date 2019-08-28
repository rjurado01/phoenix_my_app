defmodule Web.SessionController do
  use Web, :controller

  alias App.Auth
  alias Web.Guardian

  def create(conn, %{"email" => email, "password" => password}, _) do
    with {:ok, user} <- Auth.authenticate_user(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
        conn
        |> put_status(:ok)
        |> put_view(Web.UserView)
        |> render("jwt.json", jwt: token)
    else
      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(Web.ErrorView)
        |> render("401.json", message: message)
    end
  end

  def delete(conn, _params, _assigns) do
    claims = Guardian.Plug.current_claims(conn)
    user = Guardian.Plug.current_resource(conn)
    token = claims["sub"]

    Auth.remove_session(user, token)

    send_resp(conn, 204, "")
  end
end
