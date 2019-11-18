defmodule App.UserTest do
  use App.DataCase

  alias App.User

  test "changeset/2 applies correct validations" do
    changeset = User.changeset(%User{}, %{})

    assert match_array(changeset.required, [:email, :password])

    assert changeset.validations == [
      role: {:inclusion, ["client", "manager", "admin"]},
      password: {:length, [min: 8]},
      email: {:format, ~r/@/}
    ]
  end

  test "changeset/2 doesn't require password when has password_hash" do
    changeset = User.changeset(%User{password_hash: "xxx"}, %{})
    assert match_array(changeset.required, [:email])
  end
end
