defmodule App.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  use App.Model

  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :avatar, App.Avatar.Type

    field :password, :string, virtual: true
    field :password_hash, :string
    field :auth_tokens, {:array, :string}

    field :is_active, :boolean, default: false
    field :is_admin, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :is_active, :is_admin, :password])
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:email, :is_active, :is_admin, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def filter_by(:email, value) do
    dynamic([x], x.email == ^value)
  end

  defp put_password_hash(
    %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
  ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password, log_rounds: 8))
  end

  defp put_password_hash(changeset) do
    changeset
  end
end
