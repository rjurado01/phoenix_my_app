defmodule Web.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :my_app,
  module: Web.Guardian,
  error_handler: Web.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
