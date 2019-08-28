defmodule Web.UserController do
  use Web, :controller

  alias App.User

  plug :load_resource, [model: App.User] when action in ~w(show update delete)a
  plug :authorize_action, [policy: Web.UserPolicy] when action not in [:me]

  def index(conn, _params) do
    users = User.all
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- User.create(user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def show(conn, _) do
    render(conn, "show.json", user: conn.assigns.resource)
  end

  def update(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- User.update(conn.assigns.resource, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, _) do
    with {:ok, %User{}} <- User.delete(conn.assigns.resource) do
      send_resp(conn, :no_content, "")
    end
  end

  def me(conn, _params) do
    render(conn, "show.json", user: conn.assigns.current_user)
  end
end
