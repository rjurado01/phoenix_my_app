defmodule App.User do
  use App.Model

  @roles ~w[client manager admin]

  schema "users" do
    field :email, :string
    field :legal_id, :string
    field :avatar, App.Avatar.Type

    field :password, :string, virtual: true
    field :password_hash, :string
    field :auth_tokens, {:array, :string}

    field :is_active, :boolean, default: false
    field :role, :string, default: "client"

    has_many :invoices, App.Invoice, foreign_key: :owner_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, ~w[email legal_id is_active role password]a)
    |> cast_attachments(attrs, [:avatar])
    |> validate_required(~w[email]a)
    |> validate_required_password
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  # password is required only on create
  def validate_required_password(changeset) do
    if !changeset.data.password_hash do
      validate_required(changeset, [:password])
    else
      changeset
    end
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
