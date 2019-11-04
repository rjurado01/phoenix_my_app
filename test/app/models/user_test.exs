defmodule App.UserTest do
  use App.DataCase

  alias App.User

  @valid_attrs %{email: "a@email.com", is_active: true, password: "some password"}
  @update_attrs %{email: "new@email.com", is_active: false, password: "new password"}
  @invalid_attrs %{email: nil, is_active: nil, password: nil}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> User.create

    user
  end

  test "all/0 returns all users" do
    user = user_fixture()
    assert User.all == [%User{user | password: nil}]
  end

  test "find/1 returns the user with given id" do
    user = user_fixture()
    assert User.find(user.id) == %User{user | password: nil}
  end

  test "create/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = User.create(@valid_attrs)
    assert user.email == "a@email.com"
    assert user.is_active == true
    assert Bcrypt.verify_pass("some password", user.password_hash)
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = User.create(@invalid_attrs)
  end

  test "update/2 with valid data updates the user" do
    user = user_fixture()
    assert {:ok, %User{} = user} = User.update(user, @update_attrs)
    assert user.email == "new@email.com"
    assert user.is_active == false
    assert Bcrypt.verify_pass("new password", user.password_hash)
  end

  test "update/2 with invalid data returns error changeset" do
    user = user_fixture()
    assert {:error, %Ecto.Changeset{}} = User.update(user, @invalid_attrs)
    assert %User{user | password: nil} == User.find(user.id)
    assert Bcrypt.verify_pass("some password", user.password_hash)
  end

  test "delete/1 deletes the user" do
    user = user_fixture()
    assert {:ok, %User{}} = User.delete(user)
    assert_raise Ecto.NoResultsError, fn -> User.find(user.id) end
  end
end
