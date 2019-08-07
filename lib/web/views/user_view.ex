defmodule Web.UserView do
  use Web, :view
  alias Web.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      email: user.email,
      is_active: user.is_active,
      avatar_url: App.Avatar.url({user.avatar, user})
    }
  end

  def render("jwt.json", %{jwt: jwt}) do
    %{
      data: %{
        jwt: jwt
      }
    }
  end

  def render("sign_in.json", %{user: user}) do
    %{
      data: %{
        id: user.id,
        email: user.email
      }
    }
  end
end