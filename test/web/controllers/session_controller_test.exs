defmodule Web.SessionControllerTest do
  use Web.ConnCase
  alias App.User

  describe "#create" do
    test "returns valid jwt token when all is ok", %{conn: conn} do
      user = insert(:user)
      data = %{email: user.email, password: "12345678"}
      conn = post(conn, Routes.session_path(conn, :create), data)
      response = json_response(conn, 200)

      token = response["data"]["jwt"]
      {:ok, claims} = Web.Guardian.decode_and_verify(token)
      assert User.get(user.id).auth_tokens == [claims["sub"]]
    end

    test "return 401 when password is invalid", %{conn: conn} do
      user = insert(:user)
      data = %{email: user.email, password: "invalid"}
      conn = post(conn, Routes.session_path(conn, :create), data)
      json_response(conn, 401)
    end
  end
end
