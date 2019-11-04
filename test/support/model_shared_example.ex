defmodule App.ModelSharedExample do
  defmacro __using__(options) do
    quote do
      use App.DataCase

      @moduletag unquote(options)

      test "all/0 returns all users", %{subject: subject} do
        user = user_fixture()
        assert subject.all == [%{user | password: nil}]
      end
    end
  end
end
