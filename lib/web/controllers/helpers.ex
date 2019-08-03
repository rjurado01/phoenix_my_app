defmodule Web.Controllers.Helpers do
  def authorize(conn, policy, action) do
    import Plug.Conn

    current_user = Guardian.Plug.current_resource(conn)

    if apply(policy, action, [current_user, nil]) do
      conn
    else
      conn
      |> send_resp(403, "")
      |> halt()
    end
  end
end
