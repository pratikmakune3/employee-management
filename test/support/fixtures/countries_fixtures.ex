defmodule Exercise.CountriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Exercise.CountriesFixtures` context.
  """

  @doc """
  Generate a country.
  """
  def country_fixture(attrs \\ %{}) do
    {:ok, country} =
      attrs
      |> Enum.into(%{
        name: "some name",
        code: "some code"
      })
      |> Exercise.Countries.create_country()

    country
  end
end
