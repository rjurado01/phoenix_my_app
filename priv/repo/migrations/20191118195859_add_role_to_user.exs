defmodule App.Repo.Migrations.AddRoleToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string
      remove :is_admin
    end
  end
end
