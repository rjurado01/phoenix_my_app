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
  end

  scope "/api", Web do
    pipe_through [:api, :jwt_authenticated]

    resources "/users", UserController, only: [:index, :show, :create, :update, :delete]

    get "/me", UserController, :me

    delete "/session", SessionController, :delete
  end
end
