defmodule App.Auth do
  import Ecto.Query, warn: false
  alias App.Repo
  alias App.User

  def authenticate_user(email, password) do
    query = from(u in User, where: u.email == ^email)
    query |> Repo.one() |> verify_password(password)
  end

  def verify_password(nil, _) do
    Bcrypt.no_user_verify()
    {:error, "Wrong email or password"}
  end

  def verify_password(user, password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, "Wrong email or password"}
end
  end

  def generate_auth_token(user) do
    new_token = :crypto.strong_rand_bytes(24) |> Base.encode64 |> binary_part(0, 24)
    auth_tokens = (user.auth_tokens || []) ++ [new_token] |> Enum.take(-5)

    user
    |> Ecto.Changeset.change(auth_tokens: auth_tokens)
    |> App.Repo.update

    {:ok, new_token}
  end

  def get_user_by_token(token) do
    Ecto.Query.from(u in User, where: ^token in u.auth_tokens)
    |> Repo.all
    |> List.first
  end

  def remove_session(user, token) do
    auth_tokens = (user.auth_tokens || []) |> List.delete(token)

    user
    |> Ecto.Changeset.change(auth_tokens: auth_tokens)
    |> App.Repo.update
  end
end
