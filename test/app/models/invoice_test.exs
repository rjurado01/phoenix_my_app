defmodule App.InvoiceTest do
  use App.DataCase

  alias App.Invoice

  # @valid_attrs %{email: "a@email.com", is_active: true, password: "some password"}
  # @update_attrs %{email: "new@email.com", is_active: false, password: "new password"}
  # @invalid_attrs %{email: nil, is_active: nil, password: nil}

  test "all/0 returns all invoices" do
    invoice = insert(:invoice)
    assert Invoice.all == [invoice]
  end

  test "find/1 returns the invoice with given id" do
    invoice = insert(:invoice)
    assert Invoice.find(invoice.id) == invoice
  end

  test "create/1 with valid data creates a invoice" do
    attrs = Map.from_struct(build(:invoice))
    assert {:ok, %Invoice{} = invoice} = Invoice.create(attrs)
    assert invoice.number == attrs.number
    assert invoice.owner_id == attrs.owner_id
  end

  test "create/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Invoice.create(%{})
  end

  test "update/2 with valid data updates the invoice" do
    invoice = insert(:invoice)
    assert {:ok, %Invoice{} = invoice} = Invoice.update(invoice, %{total: 5})
    assert invoice.total == 5
  end

  test "update/2 with invalid data returns error changeset" do
    invoice = insert(:invoice)
    assert {:error, %Ecto.Changeset{}} = Invoice.update(invoice, %{number: nil})
  end

  test "delete/1 deletes the invoice" do
    invoice = insert(:invoice)
    assert {:ok, %Invoice{}} = Invoice.delete(invoice)
    assert_raise Ecto.NoResultsError, fn -> Invoice.find(invoice.id) end
  end
end
