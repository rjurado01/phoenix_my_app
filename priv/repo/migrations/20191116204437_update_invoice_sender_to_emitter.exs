defmodule App.Repo.Migrations.UpdateInvoiceEmittedToEmitter do
  use Ecto.Migration

  def change do
    rename table(:invoices), :sender_legal_id, to: :emitter_legal_id
  end
end
