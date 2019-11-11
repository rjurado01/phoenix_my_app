defmodule App.InvoiceTest do
  use App.DataCase

  alias App.Invoice

  @required_fields ~w[
    number
    expedition_date
    sender_legal_id
    receiver_legal_id
    concept
    total
    type
    owner_id]a

  test "changeset/2 applies correct validations" do
    changeset = Invoice.changeset(%Invoice{}, %{})

    assert match_array(changeset.required, @required_fields)

    assert changeset.validations == [
      type: {:inclusion, ["emitted", "received"]}
    ]
  end
end
