# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MyApp.Repo.insert!(%MyApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
App.User.create(%{
  email: "admin@email.com",
  password: "12345678",
  is_active: true,
  is_admin: true
})

App.User.create(%{
  email: "user1@email.com",
  password: "12345678",
  is_active: true,
  is_admin: false
})

App.User.create(%{
  email: "user2@email.com",
  password: "12345678",
  is_active: true,
  is_admin: false
})

App.User.create(%{
  email: "user3@email.com",
  password: "12345678",
  is_active: false,
  is_admin: false
})
