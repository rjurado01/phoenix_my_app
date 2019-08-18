defmodule Web.ConnCaseHelper do
  def set_auth_header(%{conn: conn, current_user: current_user}) do
    {:ok, token, _} = Web.Guardian.encode_and_sign(current_user)

    {
      :ok,
      conn: Plug.Conn.put_req_header(conn, "authorization", "bearer: " <> token),
      current_user: current_user
    }
  end

  def sign_in(%{conn: conn}) do
    user = App.Factory.insert(:user)
    set_auth_header(%{conn: conn, current_user: user})
  end

  def sign_in_admin(%{conn: conn}) do
    user = App.Factory.insert(:user_admin)
    set_auth_header(%{conn: conn, current_user: user})
  end

  def render_json(view, template, assigns) do
    view.render(template, assigns) |> format_json
  end

  defp format_json(data) do
    data |> Poison.encode! |> Poison.decode!
  end
end
