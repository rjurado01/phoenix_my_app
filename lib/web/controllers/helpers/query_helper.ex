require Ecto.Query

alias Web.Controller.ParseQueryParamsHelper

defmodule Web.Controller.QueryHelper do
  def run_query(model, params) do
    parsed_params = ParseQueryParamsHelper.parse_query_params(params)

    query = model
      |> run_filters(parsed_params.filter)
      |> run_order(parsed_params.order)

    meta = get_meta(query, parsed_params.page)

    resources = query
      |> run_pagination(parsed_params.page)
      |> App.Repo.all

    {:ok, resources, meta}
  end

  defp run_filters(model, nil) do
    model
  end

  defp run_filters(model, params) do
    model |> App.Repo.filter(params)
  end

  defp run_order(query, params) do
    order_params = Enum.map(params, fn {field, dir} -> {dir, field} end)
    Ecto.Query.order_by(query, ^order_params)
  end

  defp run_pagination(query, params) do
    query
      |> Ecto.Query.limit(^params.size)
      |> Ecto.Query.offset(^((params.number - 1) * params.size))
  end

  defp get_meta(query, params) do
    total = App.Repo.aggregate(query, :count, :id)

    %{
      total_elements: total,
      total_pages: round(total / params.size),
      page_number: params.number,
      page_size: params.size
    }
  end
end
