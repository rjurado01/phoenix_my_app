defmodule App.InvoiceFactory do
  defmacro __using__(_opts) do
    quote do
      def invoice_factory(attrs) do
        owner = if Map.has_key?(attrs, :owner_id) do
          Map.get(attrs, :owner_id) |> App.User.find
        else
          insert(:user)
        end

        data = Map.merge(%{
          owner_id: owner.id,
          type: Enum.random(["emitted", "received"]),
          number: sequence(:number, &(&1)),
          expedition_date: ~D[2000-01-01],
          emitter_legal_id: sequence(:cif, ["81168812H", "77429891T", "09514789B"]),
          receiver_legal_id: sequence(:cif, ["81168812H", "77429891T", "09514789B"]),
          concept: sequence(:concept, &"Concept #{&1}"),
          total: :rand.uniform(1000)
        }, attrs)

        data = if data.type == "received" do
          Map.put(data, :receiver_legal_id, owner.legal_id)
        else
          Map.put(data, :emitter_legal_id, owner.legal_id)
        end

        factory_changeset(App.Invoice, data)
      end
    end
  end
end
