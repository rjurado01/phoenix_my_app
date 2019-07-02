defmodule Web.UserControllerTest do
  use Web.ConnCase

  alias App.Auth
  alias App.Auth.User
  alias Web.UserView

  import Web.Guardian

  @create_attrs %{
    email: "a@email.com",
    is_active: true,
    password: "some password"
  }
  @update_attrs %{
    email: "new@email.com",
    is_active: false,
    password: "some updated password"
  }
  @invalid_attrs %{email: nil, is_active: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Auth.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp set_auth_header(%{conn: conn}) do
    user = insert(:user)

    {:ok, token, _} = encode_and_sign(user)

    {
      :ok,
      conn: put_req_header(conn, "authorization", "bearer: " <> token),
      current_user: user
    }
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  describe "index" do
    setup [:set_auth_header]

    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      users = App.Auth.list_users
      assert json_response(conn, 200) == render_json(UserView, "index.json", users: users)
    end
  end

  describe "create user" do
    setup [:set_auth_header]

    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      response = json_response(conn, 201)["data"]

      assert %{
                "id" => response["id"],
                "email" => @create_attrs.email,
                "is_active" => @create_attrs.is_active
              } == response
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user, :set_auth_header]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      assert %{
               "id" => id,
               "email" => @update_attrs.email,
               "is_active" => @update_attrs.is_active,
             } == render_json(UserView, "show.json", user: App.Auth.get_user!(id))["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user, :set_auth_header]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end
end
