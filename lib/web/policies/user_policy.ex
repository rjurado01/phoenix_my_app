defmodule Web.UserPolicy do
  import Web.ApplicationPolicy

  def index(user, _, _) do
    is_admin(user)
  end

  def show(_user, _, _) do
    true
  end

  def create(user, _, _) do
    is_admin(user)
  end

  def update(user, object, _) do
    is_admin(user) || user.id == object.id
  end

  def delete(user, _record, _) do
    is_admin(user)
  end

  def create_params(_user) do
    ~w[email is_active password avatar]
  end

  def update_params(user) do
    if is_admin(user) do
      ~w[email is_active password avatar]
    else
      ~w[email password avatar]
    end
  end
end
