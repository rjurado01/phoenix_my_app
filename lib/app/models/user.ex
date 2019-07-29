defmodule App.User do
  use Ecto.Schema
  use Arc.Ecto.Schema
  use App.Model

  import Ecto.Changeset
  import App.Avatar

  schema "users" do
    field :email, :string
    field :is_active, :boolean, default: false
    field :password, :string, virtual: true
    field :password_hash, :string
    field :auth_tokens, {:array, :string}
    field :avatar, App.Avatar.Type

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :is_active, :password])
    |> validate_required([:email, :is_active, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:avatar])
  end

  def changeset(attrs) do
    changeset(%App.User{}, attrs)
  end

  # def list do
  #   App.Repo.all(__MODULE__)
  # end

  defp put_password_hash(
    %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
  ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password, log_rounds: 8))
  end

  defp put_password_hash(changeset) do
    changeset
  end
end
