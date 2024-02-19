defmodule Exercise.Employees.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :full_name, :string
    field :job_title, :string
    field :salary, :decimal
    belongs_to :country, Exercise.Employees.Country
    belongs_to :currency, Exercise.Employees.Currency

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:full_name, :job_title, :salary, :country_id, :currency_id])
    |> validate_required([:full_name, :job_title, :salary, :country_id, :currency_id])
  end
end
