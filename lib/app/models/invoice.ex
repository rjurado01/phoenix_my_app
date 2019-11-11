defmodule App.Invoice do
  use App.Model

  @cast_fields ~w[
    number
    expedition_date
    sender_legal_id
    receiver_legal_id
    concept
    total
    type
    owner_id]a

  @required_fields ~w[
    number
    expedition_date
    sender_legal_id
    receiver_legal_id
    concept
    total
    type
    owner_id]a

  schema "invoices" do
    field :concept, :string
    field :expedition_date, :date
    field :number, :integer
    field :receiver_legal_id, :string
    field :sender_legal_id, :string
    field :total, :float
    field :type, :string

    belongs_to :owner, App.User

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, ["emitted", "received"])
  end
end
