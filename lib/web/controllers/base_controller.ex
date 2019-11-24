defmodule BaseController do
  defmacro __using__(opts) do
    model = Keyword.get(opts, :model)

    quote do
      opts = unquote(opts)

      if !opts[:actions] || Enum.member?(opts[:actions], :index) do
        def index(conn, params, _) do
          with {:ok, result, meta} <- run_query(unquote(model), params) do
            render(conn, "index.json", records: result, meta: meta)
          end
        end
      end

      if !opts[:actions] || Enum.member?(opts[:actions], :show) do
        def show(conn, _, %{record: record}) do
          render(conn, "show.json", record: record)
        end
      end

      if !opts[:actions] || Enum.member?(opts[:actions], :create) do
        def create(conn, %{"data" => params}, _) do
          with {:ok, %unquote(model){} = record} <- unquote(model).create(params) do
            conn
            |> put_status(:created)
            |> render("show.json", record: record)
          end
        end
      end

      if !opts[:actions] || Enum.member?(opts[:actions], :update) do
        def update(conn, %{"data" => params}, %{record: record}) do
          with {:ok, %unquote(model){} = record} <- unquote(model).update(record, params) do
            render(conn, "show.json", record: record)
          end
        end
      end

      if !opts[:actions] || Enum.member?(opts[:actions], :delete) do
        def delete(conn, _, %{record: record}) do
          with {:ok, %unquote(model){}} <- unquote(model).delete(record) do
            send_resp(conn, :no_content, "")
          end
        end
      end
    end
  end
end
