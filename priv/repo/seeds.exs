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
  role: "admin"
})

App.User.create(%{
  email: "manager@email.com",
  password: "12345678",
  is_active: true,
  role: "manager"
})

user = App.User.create(%{
  email: "user@email.com",
  password: "12345678",
  is_active: true,
  legal_id: "81168812H",
  role: "client"
})

App.Invoice.create(%{
  owner_id: user.id,
  type: "emitted",
  number: 1,
  expedition_date: ~D[2020-01-01],
  emitter_legal_id: "81168812H",
  receiver_legal_id: "77429891T",
  concepts: [
    %{
      description: "Concept 1",
      quantity: 2,
      price: 25.5
    }
  ]
})
