defmodule Web.StatusController do
  use Web, :controller

  def show(conn, _params, _assigns) do
    send_resp(conn, :no_content, "")
  end
end
