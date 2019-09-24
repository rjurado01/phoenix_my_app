defmodule Web.UserControllerTest do
  use Web.ConnCase
  alias App.User
  alias Web.UserView

  @create_attrs %{
    email: "a@email.com",
    is_active: true,
    password: "some password"
  }

  @update_attrs %{
    email: "new@email.com",
    is_active: false,
    is_admin: true,
    password: "some updated password",
    avatar: %Plug.Upload{path: "test/support/images/avatar.png", filename: "avatar.png"}
  }

  @invalid_attrs %{email: nil, is_active: nil, password: nil}

  def create_index_users(_) do
    insert_list(3, :user)
    :ok
  end

  describe "#index (as admin)" do
    setup [:sign_in_admin, :create_index_users]

    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      users = User.all
      assert json_response(conn, 200) == render_json(UserView, "index.json", users: users)
    end

    test "apply limit", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index), limit: 2)
      assert Enum.count(json_response(conn, 200)["data"]) == 2
    end

    test "apply sort", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index), sort: "email-")
      data = json_response(conn, 200)["data"]
      db_users = Ecto.Query.order_by(App.User, [desc: :email]) |> App.Repo.all
      assert Enum.at(data, 0)["email"] == Enum.at(db_users, 3).email
      assert Enum.at(data, 3)["email"] == Enum.at(db_users, 0).email
    end
  end

  describe "#index (as user)" do
    setup [:sign_in]

    test "returns 403", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 403)
    end
  end

  describe "#show (as user)" do
    setup [:sign_in]

    test "returns current user", %{conn: conn} do
      user = insert(:user)
      conn = get(conn, Routes.user_path(conn, :show, user))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: user)
    end

    test "returns 404 when id is invalid", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, -1))
      end
    end
  end

  describe "#create (as admin)" do
    setup [:sign_in_admin]

    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      response = json_response(conn, 201)["data"]

      assert %{
                "id" => response["id"],
                "email" => @create_attrs.email,
                "is_active" => @create_attrs.is_active,
                "avatar_url" => nil
              } == response
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "#create (as user)" do
    setup [:sign_in]

    test "returns 403", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert json_response(conn, 403)
    end
  end

  describe "#update (as me)" do
    setup [:sign_in]

    test "renders user when data is valid", %{conn: conn, current_user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      user = App.User.find(user.id)

      assert %{
               "id" => id,
               "email" => @update_attrs.email,
               "is_active" => @update_attrs.is_active,
               "avatar_url" => App.Avatar.url({user.avatar, user})
             } == render_json(UserView, "show.json", user: User.find(id))["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, current_user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "#update (as other user)" do
    setup [:sign_in]

    test "returns 403", %{conn: conn} do
      other_user = insert(:user)
      conn = put(conn, Routes.user_path(conn, :update, other_user), user: @update_attrs)
      assert json_response(conn, 403)
    end
  end

  describe "#delete (as admin)" do
    setup [:sign_in_admin]

    test "deletes chosen user", %{conn: conn} do
      user = insert(:user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end

    test "returns 404 when id is invalid", %{conn: conn} do
      assert_error_sent 404, fn ->
        delete(conn, Routes.user_path(conn, :delete, -1))
      end
    end
  end

  describe "#delete (as user)" do
    setup [:sign_in]

    test "returns 403", %{conn: conn} do
      other_user = insert(:user)
      conn = delete(conn, Routes.user_path(conn, :delete, other_user))
      assert json_response(conn, 403)
    end
  end

  describe "#me" do
    setup [:sign_in]

    test "returns current user", %{conn: conn, current_user: current_user} do
      conn = get(conn, Routes.user_path(conn, :me))
      assert json_response(conn, 200) == render_json(UserView, "show.json", user: current_user)
    end
  end
end
