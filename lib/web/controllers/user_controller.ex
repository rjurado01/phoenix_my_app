defmodule Web.UserController do
  use Web, :controller
  alias App.User

  plug :load_resource, [model: App.User] when action in ~w(show update delete)a
  plug :authorize_action, [policy: Web.UserPolicy] when action not in [:me]
  plug :authorize_params, [policy: Web.UserPolicy] when action in [:create, :update]

  def index(conn, params, _) do
    with {:ok, result, meta} <- run_query(User, params) do
      render(conn, "index.json", users: result, meta: meta)
    end
  end

  def show(conn, _, %{resource: resource}) do
    render(conn, "show.json", user: resource)
  end

  def create(conn, %{"data" => params}, _) do
    with {:ok, %User{} = user} <- User.create(params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def update(conn, %{"data" => params}, %{resource: resource}) do
    with {:ok, %User{} = user} <- User.update(resource, params) do
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
