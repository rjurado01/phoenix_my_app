defmodule Web.InvoicePolicy do
  import Web.ApplicationPolicy

  def index(user, _record, params) do
    is_manager(user) || get_in(params, ["filter", "owner_id"]) == user.id
  end

  def show(_user, _, _) do
    true
  end

  def create(user, _, _) do
    is_client(user)
  end

  def update(user, rocord, _) do
    is_owner(user, rocord)
  end

  def delete(user, rocord, _) do
    is_owner(user, rocord)
  end

  def create_params(_user) do
    ~w[number
      expedition_date
      emitter_legal_id
      receiver_legal_id
      concept
      total
      type]
  end

  def update_params(user) do
    create_params(user)
  end

  ## PRIVATE FUNCTIONS

  defp is_owner(user, rocord) do
    user.id == rocord.owner_id
  end
end
