defmodule App.Pagination do
  require Ecto.Query

  defmacro paginate(x, fields) do
    item = {{:., [], [{:__aliases__, [alias: false], [:Enum]}, :at]}, [], [fields, 0]}
    field = {:^, [], [{{:., [], [item, :field]}, [], []}]}
    value = {:^, [], [{{:., [], [item, :value]}, [], []}]}
    operator = {:^, [], [{{:., [], [item, :operator]}, [], []}]}

    query = {
      :>,
      [context: Elixir, import: Kernel],
      [
        {:field, [], [x, field]},
        value
      ]
    }

    query
  end

  def test do
    fields = [
      %{field: :field1, value: "user0@email.com", operator: :>},
      %{field: :field2, value: "user9@email.com", operator: :<}
    ]

    Ecto.Query.where(App.User, [x], paginate(x, fields))
  end
end
