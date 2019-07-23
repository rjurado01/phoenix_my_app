defmodule App.AuthServiceTest do
  use App.DataCase

  alias App.Auth

  describe "auth service" do

    test "authenticate_user/2 returns true when all is ok" do
      user = insert(:user)
      assert {:ok, user} = Auth.authenticate_user(user.email, "12345678")
    end
  end
end
