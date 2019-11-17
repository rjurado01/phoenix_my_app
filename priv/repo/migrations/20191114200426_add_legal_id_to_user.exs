defmodule App.Repo.Migrations.AddLegalIdToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :legal_id, :string
    end
  end
end
