defmodule App.Factory do
  use ExMachina.Ecto, repo: App.Repo

  def factory_changeset(module, attrs) do
    changeset = module.changeset(attrs)

    if changeset.valid? do
      info = Enum.reduce(changeset.changes, %{}, fn {field, value}, acc ->
        Map.put(acc, field, parse_value(value))
      end)

      struct(module, info)
    else
      throw(changeset)
    end
  end

  def parse_value(value) do
    cond do
      is_list(value) -> Enum.map(value, fn x -> parse_value(x) end)
      is_map(value) && Map.has_key?(value, :changes) -> value.changes
      true -> value
    end
  end

  use App.UserFactory
  use App.InvoiceFactory
end
