defmodule App.GlobalTestHelpers do
  defmacro __using__(_opts) do
    quote do
      import App.GlobalTestHelpers

      def build_attrs(model, factory) do
        Map.take(build(factory), model.__schema__(:fields))
      end
    end
  end

  def match_array(array1, array2) do
    array1 -- array2 == []
  end
end
