defmodule Exercise.Countries.Country do
  use Ecto.Schema
  import Ecto.Changeset

  schema "countries" do
    field :code, :string
    field :name, :string
    field :currency_id, :id

    has_many :employees, Exercise.Employees.Employee

    timestamps()
  end

  @doc false
  def changeset(country, attrs) do
    country
    |> cast(attrs, [:name, :code, :currency_id])
    |> validate_required([:name, :code])
    |> unique_constraint(:name)
    |> unique_constraint(:code)
  end
end
