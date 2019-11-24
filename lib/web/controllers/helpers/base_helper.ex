defmodule Web.Controller.BaseHelper do
  def authorize_action(conn, opts) do
    policy = Keyword.get(opts, :policy)
    action = conn.private.phoenix_action
    current_user = conn.assigns.current_user
    record = conn.assigns[:record]

    if apply(policy, action, [current_user, record, conn.params]) do
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

  def load_record(conn, model: model) do
    id = conn.params["id"]

    case model.get(id) do
      nil -> Web.FallbackController.call(conn, {:error, :not_found}) |> Plug.Conn.halt
      record -> Plug.Conn.assign(conn, :record, record)
    end
  end
end
