require Ecto.Query

defmodule Web.Controller.QueryHelpers do
  # {
  #   order: {name: :asc, surname: :desc},
  #   cursor: {name: 'john', surname: 'wilky'},
  #   limit: 10
  # }
  def parse_query_params(model, params) do
    with {:ok, order} <- parse_order_params(params),
         {:ok, cursor} <- parse_cursor_params(model, params),
         {:ok, limit} <- parse_limit_params(params),
         {:ok, filter} <- parse_filter_params(params)
    do
      {:ok, %{order: order, filter: filter,  cursor: cursor, limit: limit}}
    end
  end

  defp parse_order_params(params) do
    query_params = %{}

    order_info = Map.get(params, "sort")

    if order_info do
      fields = String.split(order_info, ",")

      order = Enum.reduce(fields, %{}, fn x, acc ->
        matches = Regex.run(~r/(\w+)(-?)/, x)
        field = Enum.at(matches, 1)
        dir = if Enum.at(matches, 2) == "-", do: :desc, else: :asc

        Map.put(acc, String.to_atom(field), dir)
      end)

      {:ok, order}
    else
      {:ok, nil}
    end
  end

  defp parse_cursor_params(model, params) do
    cursor = Map.get(params, "cursor")

    if cursor do
      uniq_field = Enum.find(Map.keys(cursor), fn x ->
        Enum.member?(model.uniq_fields, String.to_atom(x))
      end)

      if uniq_field, do
        {:ok, cursor}
      else
        :error
      end
    else
      {:ok, nil}
    end
  end

  defp parse_limit_params(params) do
    limit = Map.get(params, "limit")

    if is_integer(limit) && limit > 0 && limit < 50 do
      {:ok, limit}
    else
      {:ok, 20}
    end
  end

  defp parse_filter_params(params) do
    {:ok, Map.get(params, "filter")}
  end

  def run_query(model, params) do
    with {:ok, parsed_params} <- parse_query_params(model, params) do
      query = model
        |> run_filters(parsed_params.filter)
        |> run_order(parsed_params.order)
        |> run_pagination(parsed_params)

      resources = App.Repo.all(query)

      {:ok, resources, get_meta(resources, parsed_params)}
    else
      :error -> {:error, :bad_request}
    end
  end

  def run_filters(model, params) do
    if params do
      model.filter(params)
    else
      model
    end
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

      query
        |> Ecto.Query.where([x], ^pagination_query(fields, params))
        |> Ecto.Query.limit(^params.limit)
    else
      Ecto.Query.limit(query, ^params.limit)
    end
  end

  def pagination_query(fields, params) do
    [field | tail] = fields
    field_atom = String.to_atom(field)

    item = %{
      field: field_atom,
      value: params.cursor[field],
      dir: params.order[field_atom]
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
    IO.inspect item
    if item.dir == :asc do
      Ecto.Query.dynamic([x], field(x, ^item.field) > ^item.value)
    else
      Ecto.Query.dynamic([x], field(x, ^item.field) < ^item.value)
    end
  end
end
