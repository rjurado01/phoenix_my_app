defmodule Web.InvoiceControllerTest do
  use Web.ConnCase
  alias App.Repo
  alias App.Invoice
  alias App.Concept
  alias Web.InvoiceView

  describe "#index (as manager)" do
    setup [:sign_in_manager]

    setup do
      insert_list(3, :invoice) && :ok
    end

    test "lists all invoices", ~M{conn} do
      conn = get(conn, Routes.invoice_path(conn, :index))
      db_invoices = Invoice |> Repo.order([desc: :id]) |> Repo.all # default order

      assert json_response(conn, 200) == render_json(
        InvoiceView,
        "index.json",
        records: db_invoices,
        meta: %{
          total_elements: 3,
          total_pages: 0,
          page_number: 1,
          page_size: 20
        }
      )
    end

    test "apply pagination", ~M{conn} do
      conn = get(conn, Routes.invoice_path(conn, :index), page: %{number: 2, size: 2})
      db_invoices = Invoice |> Repo.order([desc: :id]) |> Repo.all
      data = json_response(conn, 200)["data"]
      assert Enum.count(data) == 1
      assert Enum.at(data, 0)["id"] == Enum.at(db_invoices, -1).id
    end

    test "apply sort", ~M{conn} do
      conn = get(conn, Routes.invoice_path(conn, :index), sort: "-number")
      data = json_response(conn, 200)["data"]
      db_invoices = Invoice |> Repo.order([desc: :number]) |> Repo.all
      assert Enum.at(data, 0)["number"] == Enum.at(db_invoices, 0).number
      assert Enum.at(data, -1)["number"] == Enum.at(db_invoices, -1).number
    end

    test "apply number filter", ~M{conn} do
      db_invoice = Invoice.last
      conn = get(conn, Routes.invoice_path(conn, :index), filter: %{number: db_invoice.number})
      data = json_response(conn, 200)["data"]
      assert Enum.count(data) == 1
      assert Enum.at(data, 0)["id"] == db_invoice.id
    end
  end

  describe "#index (as client)" do
    setup [:sign_in]

    setup %{current_user: user} do
      insert(:invoice)
      insert(:invoice, owner_id: user.id)
      :ok
    end

    test "returns 403 when tries to access all invoices", ~M{conn} do
      conn = get(conn, Routes.invoice_path(conn, :index))
      assert json_response(conn, 403)
    end

    test "returns 200 when requests his own invoices", ~M{conn, current_user} do
      conn = get(conn, Routes.invoice_path(conn, :index), filter: %{owner_id: current_user.id})
      assert Enum.count(json_response(conn, 200)["data"]) == 1
    end
  end

  describe "#show (as client)" do
    setup [:sign_in]

    test "returns current invoice", ~M{conn, current_user} do
      invoice = insert(:invoice, owner_id: current_user.id)
      conn = get(conn, Routes.invoice_path(conn, :show, invoice))
      assert json_response(conn, 200) == render_json(InvoiceView, "show.json", record: invoice)
    end

    test "returns 404 when id is invalid", ~M{conn} do
      conn = get(conn, Routes.invoice_path(conn, :show, -1))
      assert json_response(conn, 404)
    end
  end

  describe "#create (as client)" do
    setup [:sign_in]

    test "creates invoice when data is valid", ~M{conn, current_user} do
      create_attrs = build_attrs(:invoice, %{owner_id: current_user.id})
      conn = post(conn, Routes.invoice_path(conn, :create), data: create_attrs)
      assert json_response(conn, 201)
      assert Invoice.count == 1
      assert Concept.count == 1
    end

    test "renders errors when data is invalid", ~M{conn} do
      conn = post(conn, Routes.invoice_path(conn, :create), data: %{})
      response = json_response(conn, 422)
      assert Invoice.count == 0
      assert response["errors"] != %{}
    end

    test "does not creates concept when invoice is invalid", ~M{conn, current_user} do
      create_attrs = build_attrs(:invoice, %{owner_id: current_user.id}) |> Map.put(:number, nil)
      conn = post(conn, Routes.invoice_path(conn, :create), data: create_attrs)
      response = json_response(conn, 422)
      assert Invoice.count == 0
      assert Concept.count == 0
      assert response["errors"] != %{}
    end
  end

  describe "#create (as manager)" do
    setup [:sign_in_manager]

    test "returns 403", ~M{conn} do
      conn = post(conn, Routes.invoice_path(conn, :create), data: %{})
      assert json_response(conn, 403)
    end
  end

  describe "#update (as owner)" do
    setup [:sign_in]

    test "renders invoice when data is valid", ~M{conn, current_user} do
      id = insert(:invoice, owner_id: current_user.id).id
      conn = put(conn, Routes.invoice_path(conn, :update, id), data: %{number: 91})
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      invoice = Invoice.get(id)
      assert invoice.number == 91
    end

    test "renders errors when data is invalid", ~M{conn, current_user} do
      id = insert(:invoice, owner_id: current_user.id).id
      conn = put(conn, Routes.invoice_path(conn, :update, id), data: %{type: "invalid"})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 404 when id is invalid", ~M{conn} do
      conn = put(conn, Routes.invoice_path(conn, :update, "invalid"))
      assert json_response(conn, 404)
    end
  end

  describe "#update (as manager)" do
    setup [:sign_in]

    test "returns 403", ~M{conn} do
      other_invoice = insert(:invoice)
      conn = put(conn, Routes.invoice_path(conn, :update, other_invoice))
      assert json_response(conn, 403)
    end
  end

  describe "#delete (as owner)" do
    setup [:sign_in]

    test "deletes chosen invoice", ~M{conn, current_user} do
      invoice = insert(:invoice, owner_id: current_user.id)
      conn = delete(conn, Routes.invoice_path(conn, :delete, invoice))
      assert response(conn, 204)

      conn = get(conn, Routes.invoice_path(conn, :show, invoice))
      assert json_response(conn, 404)
    end

    test "returns 404 when id is invalid", ~M{conn} do
      conn = delete(conn, Routes.invoice_path(conn, :delete, -1))
      assert json_response(conn, 404)
    end
  end

  describe "#delete (as manager)" do
    setup [:sign_in_manager]

    test "returns 403", ~M{conn} do
      invoice = insert(:invoice)
      conn = delete(conn, Routes.invoice_path(conn, :delete, invoice))
      assert json_response(conn, 403)
    end
  end
end
