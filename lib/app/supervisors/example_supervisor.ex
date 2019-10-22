defmodule App.ExampleSupervisor do
  def run do
    opts = [restart: :transient]

    Task.Supervisor.start_child(__MODULE__, App.ExampleSupervisor, :test, ["1","2"], opts)
  end

  def test(a, b) do
    IO.puts "--------"
    {:ok, file} = File.open("hello", [:write])
    IO.binwrite(file, a)
    IO.binwrite(file, b)
    :timer.sleep(2000)
    File.close(file)

    # "pizza" / 3 # force error to test retries
  end
end
