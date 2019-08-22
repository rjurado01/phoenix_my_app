defmodule Web.UserController do
  use Web, :controller

  alias App.User

  action_fallback Web.FallbackController

  def policy, do: Web.UserPolicy

  def index(conn, _params) do
    with :ok <- authorize(conn) do
      users = User.all
      render(conn, "index.json", users: users)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with :ok <- authorize(conn),
         {:ok, %User{} = user} <- User.create(user_params)
    do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = User.find(id)

    with :ok <- authorize(conn, user) do
      render(conn, "show.json", user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = User.find(id)

    with :ok <- authorize(conn, user),
         {:ok, %User{} = user} <- User.update(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = User.find(id)

    with :ok <- authorize(conn, user),
         {:ok, %User{}} <- User.delete(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def me(conn, _params) do
    render(conn, "show.json", user: conn.assigns.current_user)
  end
end
