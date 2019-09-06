defmodule App.UserQuery do
  use App.Query

  def filter_by(query, {:email, value}) do
    where(query, email: ^value)
  end

  def filter_by(query, {:is_active, value}) do
    where(query, is_active: ^value)
  end

  # App.UserQuery.flter(App.User, %{email: "user1@email.com"})
  # App.UserQuery.order(App.User, %{sort: "name-"})
end
