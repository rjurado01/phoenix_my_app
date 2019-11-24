defmodule Web.InvoiceView do
  use Web, :view

  alias Web.InvoiceView

  def render("index.json", %{records: invoices, meta: meta}) do
    %{
      data: render_many(invoices, InvoiceView, "invoice.json"),
      meta: meta
    }
  end

  def render("show.json", %{record: invoice}) do
    %{data: render_one(invoice, InvoiceView, "invoice.json")}
  end

  def render("invoice.json", %{invoice: invoice}) do
    %{
      id: invoice.id,
      type: invoice.type,
      number: invoice.number,
      total: invoice.total
    }
  end
end
