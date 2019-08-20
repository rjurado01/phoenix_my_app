defmodule Web.Controllers.Helpers do
  def authorize(conn, resource, policy, action) do
    current_user = Guardian.Plug.current_resource(conn)

    if apply(policy, action, [current_user, resource]) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  def authorize(conn, resource) do
    authorize(conn, resource, conn.private.phoenix_controller.policy, conn.private.phoenix_action)
  end

  def authorize(conn) do
    authorize(conn, nil)
  end
end
