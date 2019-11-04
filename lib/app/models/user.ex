defmodule App.User do
  use App.Model

  schema "users" do
    field :email, :string
    field :avatar, App.Avatar.Type

    field :password, :string, virtual: true
    field :password_hash, :string
    field :auth_tokens, {:array, :string}

    field :is_active, :boolean, default: false
    field :is_admin, :boolean, default: false

    has_many :invoices, App.Invoice, foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, ~w[email is_active is_admin password]a)
    |> cast_attachments(attrs, [:avatar])
    |> validate_required(~w[email password]a)
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
