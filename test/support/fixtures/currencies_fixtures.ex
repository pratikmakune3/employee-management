defmodule Exercise.CurrenciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Exercise.CurrenciesFixtures` context.
  """

  @doc """
  Generate a currency.
  """
  def currency_fixture(attrs \\ %{}) do
    {:ok, currency} =
      attrs
      |> Enum.into(%{
        name: "some name",
        code: "some code",
        symbol: "some symbol"
      })
      |> Exercise.Countries.create_currency()

    currency
  end
end
