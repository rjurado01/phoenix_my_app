defmodule Web.InvoiceView do
  use Web, :view

  alias Web.InvoiceView

  def render("index.json", %{records: invoices, meta: meta}) do
    %{
      data: render_many(invoices, InvoiceView, "basic.json"),
      meta: meta
    }
  end

  def render("show.json", %{record: invoice}) do
    %{data: render_one(invoice, InvoiceView, "complete.json")}
  end

  def render("basic.json", %{invoice: invoice}) do
    %{
      id: invoice.id,
      type: invoice.type,
      number: invoice.number,
      expedition_date: invoice.expedition_date,
      emitter_legal_id: invoice.emitter_legal_id,
      receiver_legal_id: invoice.receiver_legal_id
    }
  end

  def render("complete.json", %{invoice: invoice}) do
    %{
      id: invoice.id,
      type: invoice.type,
      number: invoice.number,
      expedition_date: invoice.expedition_date,
      emitter_legal_id: invoice.emitter_legal_id,
      receiver_legal_id: invoice.receiver_legal_id,
      concepts: render_many(invoice.concepts, Web.ConceptView, "concept.json")
    }
  end
end
