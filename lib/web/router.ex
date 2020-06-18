defmodule Web.Router do
  use Web, :router

  alias Web.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
    plug Web.CurrentUser
  end

  scope "/api", Web do
    pipe_through :api

    post "/session", SessionController, :create
    get "/status", StatusController, :show
  end

  scope "/api", Web do
    pipe_through [:api, :jwt_authenticated]

    resources "/users", UserController, only: [:index, :show, :create, :update, :delete]
    resources "/invoices", InvoiceController, only: [:index, :show, :create, :update, :delete]

    get "/me", UserController, :me

    delete "/session", SessionController, :delete
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
