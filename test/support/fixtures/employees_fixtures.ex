defmodule Exercise.EmployeesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Exercise.Employees` context.
  """

  @doc """
  Generate a employee.
  """
  import Exercise.CurrenciesFixtures
  import Exercise.CountriesFixtures

  def employee_fixture(attrs \\ %{}) do
    if Map.has_key?(attrs, :currency_id) and Map.has_key?(attrs, :country_id) do
      {:ok, employee} =
        attrs
        |> Exercise.Employees.create_employee()

      employee
    else
      currency = currency_fixture()
      country = country_fixture()

      {:ok, employee} =
        attrs
        |> Enum.into(%{
          full_name: "some full_name",
          job_title: "some job_title",
          salary: 120.5,
          currency_id: currency.id,
          country_id: country.id
        })
        |> Exercise.Employees.create_employee()

      employee
    end
  end
end
