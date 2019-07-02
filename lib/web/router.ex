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

    post "/users/sign_in", UserController, :sign_in
  end

  scope "/api", Web do
    pipe_through [:api, :jwt_authenticated]

    resources "/users", UserController, except: [:new, :edit]

    get "/me", UserController, :show

    delete "/session", UserController, :sign_out
  end
end
