defmodule Web.UserControllerTest do
  use Web.ConnCase

  alias App.User
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
    {:ok, user} = User.create(@create_attrs)
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

  describe "#index" do
    setup [:set_auth_header]

    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      users = User.all
      assert json_response(conn, 200) == render_json(UserView, "index.json", users: users)
    end
  end

  describe "#show" do
    setup [:create_user, :set_auth_header]

    test "returns current user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: user)
    end
  end

  describe "#create" do
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

  describe "#update" do
    setup [:create_user, :set_auth_header]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      assert %{
               "id" => id,
               "email" => @update_attrs.email,
               "is_active" => @update_attrs.is_active,
             } == render_json(UserView, "show.json", user: User.find(id))["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "#delete" do
    setup [:create_user, :set_auth_header]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  describe "#me" do
    setup [:create_user, :set_auth_header]

    test "returns current user", %{conn: conn, current_user: current_user} do
      conn = get(conn, Routes.user_path(conn, :me))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: current_user)
    end
  end

  describe "#sign_in" do
    setup [:create_user]

    test "returns valid jwt token when all is ok", %{conn: conn, user: user} do
      data = %{email: user.email, password: "some password"}
      conn = post(conn, Routes.user_path(conn, :sign_in), data)
      response = json_response(conn, 200)

      token = response["data"]["jwt"]
      {:ok, claims} = Web.Guardian.decode_and_verify(token)
      assert User.find(user.id).auth_tokens == [claims["sub"]]
    end

    test "return 401 when password is invalid", %{conn: conn, user: user} do
      data = %{email: user.email, password: "invalid"}
      conn = post(conn, Routes.user_path(conn, :sign_in), data)
      json_response(conn, 401)
    end
  end
end
