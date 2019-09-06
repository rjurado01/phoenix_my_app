defmodule App.Query do
  defmacro __using__(_params) do
    quote do
      import Ecto.Query, only: [where: 2, where: 3, order_by: 2, limit: 2]
      import Ecto.Query.API, only: [field: 2]

      def filter(query, params) do
        Enum.reduce params, query, fn x, acc ->
          try do
            filter_by(acc, x)
          rescue ArgumentError ->
            query
          end
        end
      end

      def order(query, params) do
        order_info = Map.get(params, :sort)

        if order_info do
          fields = String.split(order_info, ",")

          order_params = Enum.reduce fields, [], fn x, acc ->
            matches = Regex.run(~r/(\w+)(-?)/, x)
            field = Enum.at(matches, 1)
            dir = if Enum.at(matches, 2) == "-", do: :desc, else: :asc

            acc ++ [{dir, String.to_atom(field)}]
          end

          order_by(query, ^order_params)
        else
          query
        end
      end

      # select id, is_admin
      # from users
      # where is_admin >= false and (is_admin != false or id > 5)
      # order by is_admin asc, id asc;

      # App.User |> Ecto.Query.where([x], x.email == "user2@email.com")
      #
      # field = :email
      # App.User |> Ecto.Query.where([x], field(x, ^field) == "user2@email.com") |> App.Repo.all
      def paginate(query \\ App.User) do
        order_field = :is_admin
        order_value = false
        id_value = 5
        limit_value = 2

        # query = Ecto.Query.dynamic([x], x.email == "iiiiii")
        # App.User |> Ecto.Query.where([x], ^query) |> App.Repo.all

        cond do
          order_field and id_value ->
            where(
              query,
              [x],
              field(x, ^order_field) >= ^order_value and
                (field(x, ^order_field) != ^order_value or x.id > ^id_value)
            ) |> limit(^limit_value)
          id_value ->
            where(query, [x], x.id > ^id_value) |> limit(^limit_value)
          true
            query |> limit(^limit_value)
        end
      end

      def example(x) do
        field(x, "value")
      end
    end
  end
end
