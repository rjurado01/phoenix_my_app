defmodule App.AuthServiceTest do
  use App.DataCase

  alias App.Auth

  describe "#authenticate_user/2" do
    test "returns user when all is ok" do
      user = insert(:user)
      assert {:ok, user} = Auth.authenticate_user(user.email, "12345678")
    end

    test "returns error when password is invalid" do
      user = insert(:user)
      assert {:error, _} = Auth.authenticate_user(user.email, "invalid")
    end
  end

  describe "#generate_auth_token/1 " do
    test "returns new token" do
      user = insert(:user)
      assert {:ok, token} = Auth.generate_auth_token(user)

      user = App.User.get(user.id)
      assert length(user.auth_tokens) == 1
      assert user.auth_tokens |> List.first == token
    end

    test "generates until 5 tokens" do
      user = insert(:user)
      assert {:ok, first_token} = Auth.generate_auth_token(user)

      for _x <- 1..4 do
        user = App.User.get(user.id)
        Auth.generate_auth_token(user)
      end

      # has generated until 5 tokens
      user = App.User.get(user.id)
      assert length(user.auth_tokens) == 5
      assert user.auth_tokens |> List.first == first_token

      # remove first token
      Auth.generate_auth_token(user)
      user = App.User.get(user.id)
      assert length(user.auth_tokens) == 5
      assert user.auth_tokens |> List.first != first_token
    end
  end

  describe "#get_user_by_token/1" do
    test "returns user with this token" do
      user = insert(:user)
      assert {:ok, token} = Auth.generate_auth_token(user)
      assert Auth.get_user_by_token(token).id == user.id
    end
  end

  describe "#remove_session/2" do
    test "removes user session token" do
      user = insert(:user)
      assert {:ok, token} = Auth.generate_auth_token(user)

      user = App.User.get(user.id)
      Auth.remove_session(user, token)

      user = App.User.get(user.id)
      assert length(user.auth_tokens) == 0
    end
  end
end
