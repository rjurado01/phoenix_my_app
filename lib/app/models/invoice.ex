defmodule App.Invoice do
  use App.Model

  @cast_fields ~w[
    number
    expedition_date
    emitter_legal_id
    receiver_legal_id
    type
    owner_id]a

  @required_fields ~w[
    number
    expedition_date
    emitter_legal_id
    receiver_legal_id
    type
    owner_id]a

  schema "invoices" do
    field :expedition_date, :date
    field :number, :integer
    field :receiver_legal_id, :string
    field :emitter_legal_id, :string
    field :type, :string

    belongs_to :owner, App.User

    has_many :concepts, App.Concept

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice = App.Repo.preload(invoice, :concepts)

    invoice
    |> cast(attrs, @cast_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:concepts, required: true)
    |> validate_required(:concepts)
    |> validate_inclusion(:type, ["emitted", "received"])
    |> validate_owner_cif
    |> assoc_constraint(:owner)
  end

  def validate_owner_cif(changeset) do
    invoice = changeset.changes
    owner = if Map.has_key?(invoice, :owner_id), do: App.User.get(invoice.owner_id), else: nil

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

  def filter_by(:number, value) do
    dynamic([x], x.number == ^value)
  end

  def filter_by(:owner_id, value) do
    dynamic([x], x.owner_id == ^value)
  end
end
