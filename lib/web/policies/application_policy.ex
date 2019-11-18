defmodule Web.ApplicationPolicy do
  def is_manager(user) do
    user.role == "manager"
  end

  def is_admin(user) do
    user.role == "admin"
  end
end
