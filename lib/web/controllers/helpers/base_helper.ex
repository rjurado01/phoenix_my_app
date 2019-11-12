defmodule Web.Controller.BaseHelper do
  def authorize_action(conn, opts) do
    policy = Keyword.get(opts, :policy)
    action = conn.private.phoenix_action
    current_user = conn.assigns.current_user
    resource = conn.assigns[:resource]

    if apply(policy, action, [current_user, resource]) do
      conn
    else
      conn |> Web.FallbackController.call({:error, :unauthorized}) |> Plug.Conn.halt
    end
  end

  def authorize_params(conn, opts) do
    policy = Keyword.get(opts, :policy)
    action = conn.private.phoenix_action
    current_user = conn.assigns.current_user

    params = case action do
      :create -> Map.take(conn.body_params["data"], policy.create_params(current_user))
      :update -> Map.take(conn.body_params["data"], policy.update_params(current_user))
      _ -> %{}
    end

    Map.merge(conn, %{"body_params" => %{"data" => params}})
  end

  def load_resource(conn, opts) do
    model = Keyword.get(opts, :model)
    id = conn.params["id"]

    case model.find(id) do
      nil -> conn |> Web.FallbackController.call({:error, :not_found}) |> Plug.Conn.halt
      resource -> Plug.Conn.assign(conn, :resource, resource)
    end
  end
end
