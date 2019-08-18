defmodule Web.Controllers.Helpers do
  def authorize(conn, policy, action, resource) do
    current_user = Guardian.Plug.current_resource(conn)

    if apply(policy, action, [current_user, resource]) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  def authorize(conn, policy, action) do
    authorize(conn, policy, action, nil)
  end

  def authorize(conn) do
    controller_name = Atom.to_string(conn.private.phoenix_controller)
    policy_name = String.replace(controller_name, "Controller", "Policy")
    policy = String.to_existing_atom(policy_name)

    authorize(conn, policy, conn.private.phoenix_action, nil)
  end
end
