defmodule Web.InvoiceController do
  use Web, :controller

  alias App.Invoice

  plug :load_record, [model: Invoice] when action in ~w(show update delete)a
  plug :authorize_action, [policy: Web.InvoicePolicy]
  plug :authorize_params, [policy: Web.InvoicePolicy] when action in [:create, :update]

  use BaseController, model: Invoice
end
