defmodule App.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        attrs = %{
          email: sequence(:email, &"user#{&1}@email.com"),
          is_active: true,
          password: "12345678"
        }

        struct(%App.User{}, App.User.changeset(attrs).changes)
      end
    end
  end
end
