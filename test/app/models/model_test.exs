defmodule App.ModelTest do
  use App.DataCase

  # use User to test App.Model module
  alias App.User

  @valid_attrs %{email: "a@email.com", is_active: true, password: "some password"}
  @update_attrs %{email: "new@email.com", is_active: false}
  @invalid_attrs %{email: nil, is_active: nil, password: nil}

  test "all/0 returns all records" do
    user = insert(:user)
    assert User.all == [%User{user | password: nil}]
  end

  test "find/1 returns the record with given id" do
    user = insert(:user)
    assert User.find(user.id) == %User{user | password: nil}
  end

  test "create/1 with valid data creates a record" do
    assert {:ok, %User{} = user} = User.create(@valid_attrs)
    assert user.email == "a@email.com"
    assert user.is_active == true
    assert Bcrypt.verify_pass("some password", user.password_hash)
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{} = changeset} = User.create(@invalid_attrs)
  end

  test "update/2 with valid data updates the record" do
    user = insert(:user)
    assert {:ok, %User{} = user} = User.update(user, @update_attrs)
    assert user.email == "new@email.com"
    assert user.is_active == false
  end

  test "update/2 with invalid data returns error changeset" do
    user = insert(:user)
    assert {:error, %Ecto.Changeset{}} = User.update(user, @invalid_attrs)
    assert %User{user | password: nil} == User.find(user.id)
    assert Bcrypt.verify_pass("12345678", user.password_hash)
  end

  test "delete/1 deletes the record" do
    user = insert(:user)
    assert {:ok, %User{}} = User.delete(user)
    assert_raise Ecto.NoResultsError, fn -> User.find(user.id) end
  end
end
