defmodule Web.ConceptView do
  use Web, :view

  alias Web.ConceptView

  def render("index.json", %{records: concepts, meta: meta}) do
    %{
      data: render_many(concepts, ConceptView, "concept.json"),
      meta: meta
    }
  end

  def render("show.json", %{record: concept}) do
    %{data: render_one(concept, ConceptView, "concept.json")}
  end

  def render("concept.json", %{concept: concept}) do
    %{
      id: concept.id,
      quantity: concept.quantity,
      price: concept.price
    }
  end
end
