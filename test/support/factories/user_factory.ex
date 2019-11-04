defmodule App.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        factory_changeset(App.User, %{
          email: sequence(:email, &"user#{&1}@email.com"),
          is_active: true,
          password: "12345678"
        })
      end

      def user_admin_factory do
        struct!(
          user_factory,
          %{
            is_admin: true
          }
        )
      end
    end
  end
end
