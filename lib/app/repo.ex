defmodule App.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query, only: [order_by: 2, where: 3]

  def first(query) do
    query |> Ecto.Query.first |> one
  end

  def last(query) do
    query |> Ecto.Query.last |> one
  end

  def count(query) do
    query |> aggregate(:count, :id)
  end

  def find(query, id) do
    query |> get!(id)
  end

  def order(query, params) do
    query |> order_by(^params)
  end

  def filter(module, params) do
    Enum.reduce(params, module, fn {field, value}, acc ->
      try do
        field_name = if is_atom(field), do: field, else: String.to_atom(field)
        where(acc, [x], ^module.filter_by(field_name, value))
      rescue
        ArgumentError -> acc
      end
    end)
  end
end
