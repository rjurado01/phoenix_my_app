defmodule Web.StatusController do
  use Web, :controller

  def show(conn, _params, _assigns) do
    conn
    |> put_status(204)
    |> json("")
  end
end
