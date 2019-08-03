defmodule Web.UserPolicy do
  alias App.User

  def index(_, _), do: true

  def update(current_user, object) do
    current_user.id == object.id
  end
end
