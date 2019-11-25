defmodule App.Repo.Migrations.CreateInvoiceConcept do
  use Ecto.Migration

  def change do
    create table(:concepts) do
      add :description, :string
      add :quantity,  :integer
      add :price, :float
      add :invoice_id, references(:invoices, on_delete: :delete_all)

      timestamps()
    end

    alter table("invoices") do
      remove :concept
      remove :total
    end
  end
end
