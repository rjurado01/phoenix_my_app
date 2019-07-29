defmodule App.Model do
  alias App.Repo

  defmacro __using__(_params) do
    quote do
      def all do
        Repo.all(__MODULE__)
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
        |> __MODULE__.update_changeset(attrs)
        |> Repo.update()
      end

      def delete(object) do
        Repo.delete(object)
      end
    end
  end
end
