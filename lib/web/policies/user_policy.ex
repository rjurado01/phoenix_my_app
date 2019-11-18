defmodule Web.UserPolicy do
  import Web.ApplicationPolicy

  def index(user, _) do
    is_admin(user)
  end

  def show(_user, _) do
    true
  end

  def create(user, _) do
    is_admin(user)
  end

  def update(user, object) do
    is_admin(user) || user.id == object.id
  end

  def delete(user, _object) do
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
