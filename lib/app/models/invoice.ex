defmodule App.Invoice do
  use App.Model

  @cast_fields ~w[
    number
    expedition_date
    emitter_legal_id
    receiver_legal_id
    concept
    total
    type
    owner_id]a

  @required_fields ~w[
    number
    expedition_date
    emitter_legal_id
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
    field :emitter_legal_id, :string
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
    |> validate_owner_cif
    |> assoc_constraint(:owner)
  end

  def validate_owner_cif(changeset) do
    invoice = changeset.changes
    owner = if Map.has_key?(invoice, :owner_id), do: App.User.find(invoice.owner_id), else: nil

    cond do
      !owner ->
        changeset
      invoice.type == "emitter" && Map.get(invoice, :emitter_legal_id) != owner.legal_id ->
        add_error(changeset, :emitter_legal_id, "invalid", [validation: :invalid])
      invoice.type == "received" && Map.get(invoice, :receiver_legal_id) != owner.legal_id ->
        add_error(changeset, :receiver_legal_id, "invalid", [validation: :invalid])
      true ->
        changeset
    end
  end
end
