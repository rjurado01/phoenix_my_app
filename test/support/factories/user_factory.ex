defmodule App.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %App.User{
          email: sequence(:email, &"user#{&1}@email.com"),
          is_active: true,
          password: "12345678"
        }
      end
    end
  end
end
