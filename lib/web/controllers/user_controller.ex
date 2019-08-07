defmodule Web.UserController do
  use Web, :controller

  alias App.Auth
  alias App.User
  alias Web.Guardian

  action_fallback Web.FallbackController

  def index(conn, _params) do
    # authorize(conn, Web.UserPolicy, :index)

    users = Mongo.find(:mongo, "users", %{}) |> Enum.to_list()

    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(200, Poison.encode!(users))

    # users = User.all
    # render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- User.create(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = User.find(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = User.find(id)

    with {:ok, %User{} = user} <- User.update(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = User.find(id)

    with {:ok, %User{}} <- User.delete(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "show.json", user: user)
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
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

  def sign_out(conn, _params) do
    claims = Guardian.Plug.current_claims(conn)
    user = Guardian.Plug.current_resource(conn)
    token = claims["sub"]

    Auth.remove_session(user, token)

    send_resp(conn, 204, "")
  end
end
