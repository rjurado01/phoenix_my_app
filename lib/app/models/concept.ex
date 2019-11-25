defmodule App.Concept do
  use App.Model

  @fields ~w[description quantity price]a

  schema "concepts" do
    field :description, :string
    field :quantity, :integer
    field :price, :float

    belongs_to :invoice, App.Invoice

    timestamps()
  end

  def changeset(concept, attrs) do
    concept
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> assoc_constraint(:invoice)
  end
end
