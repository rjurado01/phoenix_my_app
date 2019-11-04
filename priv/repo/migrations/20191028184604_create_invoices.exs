defmodule MyApp.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :type, :string
      add :number, :integer
      add :expedition_date, :date
      add :sender_legal_id, :string
      add :receiver_legal_id, :string
      add :concept, :string
      add :total, :float
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:invoices, [:owner_id])
  end
end
