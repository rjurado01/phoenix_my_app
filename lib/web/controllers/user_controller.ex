defmodule Web.UserController do
  use Web, :controller

  alias App.User

  plug :load_resource, [model: App.User] when action in ~w(show update delete)a
  plug :authorize_action, [policy: Web.UserPolicy] when action not in [:me]

  def index(conn, params, _) do
    with {:ok, query} <- run_query(User, params) do
      users = App.Repo.all(query)
      render(conn, "index.json", users: users)
    end
  end

  def create(conn, %{"user" => user_params}, _) do
    with {:ok, %User{} = user} <- User.create(user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def show(conn, _, %{resource: resource}) do
    render(conn, "show.json", user: resource)
  end

  def update(conn, %{"user" => user_params}, %{resource: resource}) do
    with {:ok, %User{} = user} <- User.update(resource, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, _, %{resource: resource}) do
    with {:ok, %User{}} <- User.delete(resource) do
      send_resp(conn, :no_content, "")
    end
  end

  def me(conn, _, %{current_user: current_user}) do
    render(conn, "show.json", user: current_user)
  end
end
