# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Exercise.Repo.insert!(%Exercise.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Exercise.Countries
alias Exercise.Employees

# Seed the 8 supported currencies
# Euro (EUR)
# UK Pound Sterling (GBP)
# Australian Dollar (AUD)
# New Zealand Dollar (NZD)
# Unites States Dollar (USD)
# Canadian Dollar (CAD)
# Swiss Franc (CHF)
# Japanese Yen (JPY)
currency_data = [
  ["European Euro", "EUR", "€"],
  ["United Kingdom Pound Sterling", "GBP", "£"],
  ["Australian Dollar", "AUD", "$"],
  ["New Zealand Dollar", "NZD", "$"],
  ["United States Dollar", "USD", "$"],
  ["Canadian Dollar", "CAD", "$"],
  ["Swiss Franc", "CHF", "¥"],
  ["Japanese Yen", "JPY", "CHF"]
]

for currency <- currency_data do
  [name, code, symbol] = currency

  {:ok, _currency} =
    Countries.create_currency(%{
      name: name,
      code: code,
      symbol: symbol
    })
end

# Seed the 12 supported countries
country_data = [
  ["Australia", "AUS", "AUD"],
  ["Canada", "CAN", "CAD"],
  ["France", "FRA", "EUR"],
  ["Japan", "JPN", "JPY"],
  ["Italy", "ITA", "EUR"],
  ["Liechtenstein", "LIE", "CHF"],
  ["New Zealand", "NZL", "NZD"],
  ["Portugal", "PRT", "EUR"],
  ["Spain", "ESP", "EUR"],
  ["Switzerland", "CHE", "CHF"],
  ["United Kingdom", "GBR", "GBP"],
  ["United States", "USA", "USD"]
]

for country <- country_data do
  [name, code, currency_code] = country
  currency = Countries.get_currency_by_code!(currency_code)

  {:ok, _country} =
    Countries.create_country(%{
      name: name,
      code: code,
      currency_id: currency.id
    })
end

defmodule EmployeeSeeder do
  def seedEmployees(count) do
    first_names = File.read!("priv/data/first_names.txt") |> String.split("\n")
    last_names = File.read!("priv/data/last_names.txt") |> String.split("\n")
    job_titles = File.read!("priv/data/job_titles.txt") |> String.split("\n") |> Enum.take(100)

    country_ids = Countries.list_countries() |> Enum.map(& &1.id)
    currency_ids = Countries.list_currencies() |> Enum.map(& &1.id)

    for x <- 1..count do
      employee = generate_employee(first_names, last_names, job_titles, country_ids, currency_ids)
      Employees.create_employee(employee)
    end
  end

  defp generate_employee(first_names, last_names, job_titles, country_ids, currency_ids) do
    full_name = generate_full_name(first_names, last_names)
    job_title = Enum.random(job_titles)
    country = Enum.random(country_ids)
    salary = generate_salary()
    currency = Enum.random(currency_ids)

    %{
      full_name: full_name,
      job_title: job_title,
      country_id: country,
      salary: salary,
      currency_id: currency
    }
  end

  defp generate_full_name(first_names, last_names) do
    "#{Enum.random(first_names)} #{Enum.random(last_names)}"
  end

  defp generate_salary() do
    Enum.random(1_000_000..9_000_000)
  end
end

EmployeeSeeder.seedEmployees(10000)
