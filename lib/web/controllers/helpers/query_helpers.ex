require Ecto.Query

defmodule Web.Controller.QueryHelpers do
  # {
  #   order: {name: :asc, surname: :desc},
  #   cursor: {name: 'john', surname: 'wilky'},
  #   limit: 10
  # }
  def parse_query_params(params) do
    query_params = %{
      order: parse_order_params(params),
      filter: Map.get(params, :filter),
      cursor: Map.get(params, :cursor),
      limit: Map.get(params, :limit)
    }

    if is_map(query_params.cursor) and
       is_map(query_params.order) and
       Map.keys(query_params.cursor) -- Map.keys(query_params.order) != []
    do
      {:error, :bad_request}
    else
      {:ok, query_params}
    end
  end

  defp parse_order_params(params) do
    query_params = %{}

    order_info = Map.get(params, :sort)

    if order_info do
      fields = String.split(order_info, ",")

      Enum.reduce(fields, %{}, fn x, acc ->
        matches = Regex.run(~r/(\w+)(-?)/, x)
        field = Enum.at(matches, 1)
        dir = if Enum.at(matches, 2) == "-", do: :desc, else: :asc

        Map.put(acc, String.to_atom(field), dir)
      end)
    end
  end

  def run_query(query, params) do
    {:ok, parsed_params} = parse_query_params(params)

    query
      |> run_filters(parsed_params.filter)
      |> run_order(parsed_params.order)
      |> run_pagination(parsed_params)
  end

  def run_filters(query, params) do
    Enum.reduce(params, query, fn x, acc ->
      try do
        query.filter_by(acc, x)
      rescue ArgumentError ->
        query
      end
    end)
  end

  def run_order(query, params) do
    if params do
      order_params = Enum.map(params, fn {field, dir} -> {dir, field} end)

      Ecto.Query.order_by(query, ^order_params)
    else
      query
    end
  end

  def run_pagination(query, params) do
    if params.cursor do
      fields = Map.keys(params.cursor)
      limit = Map.keys(params.limit) || 10

      query
        |> Ecto.Query.where([x], ^pagination_query(fields, params))
        |> Ecto.Query.limit(^limit)
    else
      query
    end
  end

  def pagination_query(fields, params) do
    [field | tail] = fields

    item = %{
      field: field,
      value: params.cursor[field],
      dir: params.order[field]
    }

    if Enum.count(tail) > 0 do
      item_query = pagination_item_condition(item)

      Ecto.Query.dynamic(
        [x],
        ^item_query or (field(x, ^item.field) == ^item.value and ^pagination_query(tail, params))
      )
    else
      pagination_item_condition(item)
    end
  end


  def pagination_item_condition(item) do
    if item.dir == :asc do
      Ecto.Query.dynamic([x], field(x, ^item.field) > ^item.value)
    else
      Ecto.Query.dynamic([x], field(x, ^item.field) < ^item.value)
    end
  end
end
