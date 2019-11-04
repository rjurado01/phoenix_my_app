defmodule App.InvoiceFactory do
  defmacro __using__(_opts) do
    quote do
      def invoice_factory do
        factory_changeset(App.Invoice, %{
          number: sequence(:number, &(&1)),
          expedition_date: ~D[2000-01-01],
          sender_legal_id: "70876900P",
          receiver_legal_id: sequence(:cif, ["81168812H", "77429891T", "09514789B"]),
          concept: sequence(:concept, &"Concept #{&1}"),
          total: :rand.uniform(1000),
          type: Enum.random(["emitted", "received"]),
          owner_id: insert(:user).id
        })
      end
    end
  end
end
