defmodule Web.UserControllerTest do
  use Web.ConnCase
  alias App.User
  alias App.Repo
  alias Web.UserView

  @create_attrs %{
    email: "a@email.com",
    is_active: true,
    password: "some password"
  }

  @update_attrs %{
    email: "new@email.com",
    is_active: false,
    password: "some updated password",
    avatar: %Plug.Upload{path: "test/support/images/avatar.png", filename: "avatar.png"}
  }

  @meta %{
    total_elements: 4,
    total_pages: 0,
    page_number: 1,
    page_size: 20
  }

  @invalid_attrs %{email: nil, is_active: nil, password: nil}

  describe "#index (as admin)" do
    setup [:sign_in_admin]

    setup do
      insert_list(3, :user) && :ok
    end

    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      db_users = User |> Repo.order([desc: :id]) |> Repo.all # default order
      assert json_response(conn, 200) ==
        render_json(UserView, "index.json", records: db_users, meta: @meta)
    end

    test "apply pagination", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index), page: %{number: 2, size: 2})
      db_users = User |> Repo.order([desc: :id]) |> Repo.all
      data = json_response(conn, 200)["data"]
      assert Enum.count(data) == 2
      assert Enum.at(data, 0)["email"] == Enum.at(db_users, 2).email
    end

    test "apply sort", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index), sort: "-email")
      data = json_response(conn, 200)["data"]
      db_users = User |> Repo.order([desc: :email]) |> Repo.all
      assert Enum.at(data, 0)["email"] == Enum.at(db_users, 0).email
      assert Enum.at(data, 3)["email"] == Enum.at(db_users, 3).email
    end

    test "apply email filter", %{conn: conn} do
      db_user = User.last
      conn = get(conn, Routes.user_path(conn, :index), filter: %{email: db_user.email})
      data = json_response(conn, 200)["data"]
      assert Enum.count(data) == 1
      assert Enum.at(data, 0)["id"] == db_user.id
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
      assert json_response(conn, 200) == render_json(UserView, "show.json", record: user)
    end

    test "returns 404 when id is invalid", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :show, -1))
      assert json_response(conn, 404)
    end
  end

  describe "#create (as admin)" do
    setup [:sign_in_admin]

    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: @create_attrs)
      response = json_response(conn, 201)["data"]

      assert %{
                "id" => response["id"],
                "email" => @create_attrs.email,
                "is_active" => @create_attrs.is_active,
                "avatar_url" => nil
              } == response
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: @invalid_attrs)
      response = json_response(conn, 422)
      assert response["errors"] != %{}
      assert response["errors"] |> Map.keys == ["email", "password"]
    end
  end

  describe "#create (as user)" do
    setup [:sign_in]

    test "returns 403", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), data: @create_attrs)
      assert json_response(conn, 403)
    end
  end

  describe "#update (as me)" do
    setup [:sign_in]

    test "renders user when data is valid", %{conn: conn, current_user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), data: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      user = User.get(user.id)

      assert %{
               "id" => id,
               "email" => @update_attrs.email,
               "is_active" => @update_attrs.is_active,
               "avatar_url" => App.Avatar.url({user.avatar, user})
             } == render_json(UserView, "show.json", record: User.get(id))["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, current_user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), data: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "#update (as other user)" do
    setup [:sign_in]

    test "returns 403", %{conn: conn} do
      other_user = insert(:user)
      conn = put(conn, Routes.user_path(conn, :update, other_user), data: @update_attrs)
      assert json_response(conn, 403)
    end
  end

  describe "#delete (as admin)" do
    setup [:sign_in_admin]

    test "deletes chosen user", %{conn: conn} do
      user = insert(:user)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert json_response(conn, 404)
    end

    test "returns 404 when id is invalid", %{conn: conn} do
      conn = delete(conn, Routes.user_path(conn, :delete, -1))
      assert json_response(conn, 404)
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
      assert json_response(conn, 200) == render_json(UserView, "show.json", record: current_user)
    end
  end
end
