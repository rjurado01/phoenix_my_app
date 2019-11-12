defmodule Web.UserPolicy do
  def index(current_user, _) do
    current_user.is_admin
  end

  def show(_current_user, _) do
    true
  end

  def create(current_user, _) do
    current_user.is_admin
  end

  def update(current_user, object) do
    current_user.is_admin || current_user.id == object.id
  end

  def delete(current_user, _object) do
    current_user.is_admin
  end

  def create_params(_current_user) do
    ~w[email is_active password avatar]
  end

  def update_params(current_user) do
    if current_user.is_admin do
      ~w[email is_active password avatar]
    else
      ~w[email password avatar]
    end
  end
end
