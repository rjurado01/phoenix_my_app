defmodule App.Factory do
  use ExMachina.Ecto, repo: App.Repo

  def factory_changeset(module, attrs) do
    changeset = module.changeset(attrs)

    if changeset.valid? do
      struct(module, changeset.changes)
    else
      throw(changeset)
    end
  end

  use App.UserFactory
  use App.InvoiceFactory
end
