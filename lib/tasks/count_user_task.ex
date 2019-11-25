defmodule Mix.Tasks.CountUsersTask do
  use Mix.Task

  # run command: mix count_users_task
  def run(_) do
    Mix.Task.run "app.start", []

    IO.puts "Hello World!"
    IO.inspect App.User.count
  end
end
