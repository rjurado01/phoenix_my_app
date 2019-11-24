defmodule Web.UserController do
  use Web, :controller

  alias App.User

  plug :load_record, [model: User] when action in ~w(show update delete)a
  plug :authorize_action, [policy: Web.UserPolicy] when action not in [:me]
  plug :authorize_params, [policy: Web.UserPolicy] when action in [:create, :update]

  use BaseController, model: User

  def me(conn, _, %{current_user: current_user}) do
    render(conn, "show.json", record: current_user)
  end
end
