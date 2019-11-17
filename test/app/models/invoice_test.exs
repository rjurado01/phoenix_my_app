defmodule App.InvoiceTest do
  use App.DataCase

  alias App.Invoice

  @required_fields ~w[
    number
    expedition_date
    emitter_legal_id
    receiver_legal_id
    concept
    total
    type
    owner_id]a

  describe "changeset/2" do
    test "applies correct validations" do
      changeset = Invoice.changeset(%Invoice{}, %{})
      assert match_array(changeset.required, @required_fields)
      assert changeset.validations == [
        type: {:inclusion, ["emitted", "received"]}
      ]
    end

    test "validates receiver_legal_id when type is receiver" do
      owner = insert(:user)
      changeset = Invoice.changeset(%Invoice{}, %{
        type: "received", receiver_legal_id: "not_owner_legal_id", owner_id: owner.id
      })
      assert Keyword.get(changeset.errors, :receiver_legal_id) ==
        {"invalid", [validation: :invalid]}

      changeset = Invoice.changeset(%Invoice{}, %{
        type: "received", receiver_legal_id: owner.legal_id, owner_id: owner.id
      })
      assert Keyword.get(changeset.errors, :receiver_legal_id) == nil
    end

    test "validates sender_legal_id when type is emitter" do
      owner = insert(:user)
      changeset = Invoice.changeset(%Invoice{}, %{
        type: "emitter", emitter_legal_id: "not_owner_legal_id", owner_id: owner.id
      })
      assert Keyword.get(changeset.errors, :emitter_legal_id) ==
        {"invalid", [validation: :invalid]}

      changeset = Invoice.changeset(%Invoice{}, %{
        type: "emitter", emitter_legal_id: owner.legal_id, owner_id: owner.id
      })
      assert Keyword.get(changeset.errors, :emitter_legal_id) == nil
    end
  end

  test "create/1 data creates an invoice with valid" do
    attrs = build_attrs(Invoice, :invoice)
    assert {:ok, %Invoice{} = record} = Invoice.create(attrs)
  end
end
