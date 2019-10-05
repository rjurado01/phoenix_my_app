defmodule App.Model do
  alias App.Repo

  defmacro __using__(_params) do
    quote do
      import Ecto.Query

      def changeset(attrs) do
        changeset(struct(__MODULE__), attrs)
      end

      def all do
        Repo.all(__MODULE__)
      end

      def last do
        Repo.one(from x in __MODULE__, order_by: [desc: x.id], limit: 1)
      end

      def find(id) do
        Repo.get!(__MODULE__, id)
      end

      def create(attrs \\ %{}) do
        struct(__MODULE__)
        |> __MODULE__.changeset(attrs)
        |> Repo.insert()
      end

      def update(object, attrs) do
        object
        |> __MODULE__.changeset(attrs)
        |> Repo.update()
      end

      def delete(object) do
        Repo.delete(object)
      end

      def order_by(params) do
        order_by(__MODULE__, ^params)
      end

      def filter(params) do
        Enum.reduce(params, __MODULE__, fn {field, value}, acc ->
          try do
            where(acc, [x], ^filter_by(String.to_atom(field), value))
          rescue
            ArgumentError -> acc
          end
        end)
      end
    end
  end
end
