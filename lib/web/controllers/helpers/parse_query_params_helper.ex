defmodule Web.Controller.ParseQueryParamsHelper do
  # params: {
  #   order: {name: :asc, surname: :desc},
  #   cursor: {name: 'john', surname: 'wilky'},
  #   limit: 10
  # }
  def parse_query_params(params) do
    with filter <- parse_filter_params(params),
         order <- parse_order_params(params),
         page <- parse_page_params(params)
    do
      %{order: order, filter: filter,  page: page}
    end
  end

  defp parse_filter_params(params) do
    Map.get(params, "filter")
  end

  defp parse_order_params(%{"sort" => order_info}) when order_info not in [nil, ""] do
    fields = String.split(order_info, ",")

    Enum.reduce(fields, %{}, fn x, acc ->
      matches = Regex.run(~r/(\w+)(-?)/, x)
      field = Enum.at(matches, 1)
      dir = if Enum.at(matches, 2) == "-", do: :desc, else: :asc

      Map.put(acc, String.to_atom(field), dir)
    end)
  end

  defp parse_order_params(_) do
    [id: :desc]
  end

  defp parse_page_params(%{"page" => page_params}) do
    %{
      size: parse_page_size(page_params),
      number: parse_page_number(page_params)
    }
  end

  defp parse_page_params(_) do
    %{size: parse_page_size(nil), number: 1}
  end

  defp parse_page_size(%{"size" => size}) when size not in [nil, ""] do
    size
  end

  defp parse_page_size(_) do
    20
  end

  defp parse_page_number(%{"number" => number}) when number not in [nil, ""] do
    number
  end

  defp parse_page_number(_) do
    1
  end
end

