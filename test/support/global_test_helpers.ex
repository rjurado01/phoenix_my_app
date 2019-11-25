defmodule App.GlobalTestHelpers do
  defmacro __using__(_opts) do
    quote do
      import App.Factory
      import ShorterMaps
      import App.GlobalTestHelpers

      def build_attrs(factory, attrs) do
        factory_struct = build(factory, attrs)
        fields = factory_struct.__struct__.__schema__(:fields)
        associations = factory_struct.__struct__.__schema__(:associations)

        Map.take(factory_struct, fields ++ associations)
      end

      def build_attrs(factory) do
        build_attrs(factory, %{})
      end
    end
  end

  def match_array(array1, array2) do
    array1 -- array2 == []
  end
end
