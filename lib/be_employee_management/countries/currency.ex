defmodule Exercise.Countries.Currency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "currencies" do
    field :code, :string
    field :name, :string
    field :symbol, :string

    has_many :employees, Exercise.Employees.Employee

    timestamps()
  end

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, [:code, :name, :symbol])
    |> validate_required([:code, :name, :symbol])
    |> unique_constraint(:name)
    |> unique_constraint(:code)
  end
end
