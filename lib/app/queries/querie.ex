defmodule App.Query do
  defmacro __using__(_params) do
    quote do
      import Ecto.Query, only: [where: 2, where: 3, order_by: 2, limit: 2]
      import Ecto.Query.API, only: [field: 2]

      def filter(query, params) do
        Enum.reduce(params, query, fn x, acc ->
          try do
            filter_by(acc, x)
          rescue
            ArgumentError ->
              query
          end
        end)
      end

      def order(query, params) do
        order_info = Map.get(params, :sort)

        if order_info do
          fields = String.split(order_info, ",")

          order_params =
            Enum.reduce(fields, [], fn x, acc ->
              matches = Regex.run(~r/(\w+)(-?)/, x)
              field = Enum.at(matches, 1)
              dir = if Enum.at(matches, 2) == "-", do: :desc, else: :asc

              acc ++ [{dir, String.to_atom(field)}]
            end)

          query |>
            order_by(^order_params)
          #where([x], ^pagination_query())
        else
          query
        end
      end


      defp dynamic_item_condition(item) do
        if item.operator == :> do
          Ecto.Query.dynamic([x], field(x, ^item.field) > ^item.value)
        else
          Ecto.Query.dynamic([x], field(x, ^item.field) < ^item.value)
        end
      end

      defp dynamic_queries(fields) do
        [item | tail] = fields

        if Enum.count(tail) > 0 do
          item_query = dynamic_item_condition(item)

          Ecto.Query.dynamic(
            [x],
            ^item_query or (field(x, ^item.field) == ^item.value and ^dynamic_queries(tail))
          )
        else
          dynamic_item_condition(item)
        end
      end
    end
  end
end
