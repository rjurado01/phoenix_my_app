defmodule Web.Router do
  use Web, :router

  alias Web.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/api", Web do
    pipe_through :api

    post "/session", UserController, :sign_in

    resources "/users", UserController, only: [:index, :show, :create, :update, :delete]
  end

  scope "/api", Web do
    pipe_through [:api, :jwt_authenticated]


    get "/me", UserController, :me

    delete "/session", UserController, :sign_out
  end
end
