defmodule Web.RoomChannel do
  use Phoenix.Channel

  def join("room:all", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> private_room_id, _params, socket) do
    if private_room_id != socket.assigns[:user_id] do
      {:error, %{reason: "unauthorized"}}
    else
      {:ok, socket}
    end
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end
