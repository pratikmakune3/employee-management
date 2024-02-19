defmodule Exercise.Repo do
  use Ecto.Repo,
    otp_app: :be_employee_managment,
    adapter: Ecto.Adapters.Postgres
end
