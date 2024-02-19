defmodule Exercise.EmployeesTest do
  use Exercise.DataCase

  alias Exercise.Employees

  describe "employees" do
    alias Exercise.Employees.Employee

    import Exercise.EmployeesFixtures
    import Exercise.CurrenciesFixtures
    import Exercise.CountriesFixtures

    @invalid_attrs %{
      full_name: nil,
      job_title: nil,
      salary: nil,
      currency_id: nil,
      country_id: nil
    }

    test "list_employees/0 returns all employees" do
      employee = employee_fixture()
      assert Employees.list_employees() == [employee]
    end

    test "get_employee!/1 returns the employee with given id" do
      employee = employee_fixture()
      assert Employees.get_employee!(employee.id) == employee
    end

    test "create_employee/1 with valid data creates a employee" do
      currency = currency_fixture()
      country = country_fixture()

      country =
        valid_attrs = %{
          full_name: "some full_name",
          job_title: "some job_title",
          salary: "120.5",
          currency_id: currency.id,
          country_id: country.id
        }

      assert {:ok, %Employee{} = employee} = Employees.create_employee(valid_attrs)
      assert employee.full_name == "some full_name"
      assert employee.job_title == "some job_title"
      assert employee.salary == Decimal.new("120.5")
    end

    test "create_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Employees.create_employee(@invalid_attrs)
    end

    test "update_employee/2 with valid data updates the employee" do
      employee = employee_fixture()

      currency =
        currency_fixture(%{
          name: "some another name",
          code: "some another code",
          symbol: "some another symbol"
        })

      country =
        country_fixture(%{
          name: "some another name",
          code: "some another code"
        })

      update_attrs = %{
        full_name: "some updated full_name",
        job_title: "some updated job_title",
        salary: "456.7",
        currency_id: currency.id,
        country_id: country.id
      }

      assert {:ok, %Employee{} = employee} = Employees.update_employee(employee, update_attrs)
      assert employee.full_name == "some updated full_name"
      assert employee.job_title == "some updated job_title"
      assert employee.salary == Decimal.new("456.7")
      assert employee.currency_id == currency.id
      assert employee.country_id == country.id
    end

    test "update_employee/2 with invalid data returns error changeset" do
      employee = employee_fixture()
      assert {:error, %Ecto.Changeset{}} = Employees.update_employee(employee, @invalid_attrs)
      assert employee == Employees.get_employee!(employee.id)
    end

    test "delete_employee/1 deletes the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{}} = Employees.delete_employee(employee)
      assert_raise Ecto.NoResultsError, fn -> Employees.get_employee!(employee.id) end
    end

    test "change_employee/1 returns a employee changeset" do
      employee = employee_fixture()
      assert %Ecto.Changeset{} = Employees.change_employee(employee)
    end

    test "get_employees_by_country/1 returns a list of employees filtered by country_id" do
      currency1 =
        currency_fixture(%{
          name: "currency1",
          code: "currency1 code",
          symbol: "currency1 symbol"
        })

      currency2 =
        currency_fixture(%{
          name: "currency2",
          code: "currency2 code",
          symbol: "currency2 symbol"
        })

      country1 =
        country_fixture(%{
          name: "country1",
          code: "country1 code"
        })

      country2 =
        country_fixture(%{
          name: "country2",
          code: "country2 code"
        })

      employee1 =
        employee_fixture(%{
          full_name: "employee1 fullname",
          job_title: "job_title_1",
          salary: 6_000_000,
          currency_id: currency1.id,
          country_id: country1.id
        })

      employee2 =
        employee_fixture(%{
          full_name: "employee2 full_name",
          job_title: "job_title_1",
          salary: 7_000_000,
          currency_id: currency1.id,
          country_id: country1.id
        })

      employee3 =
        employee_fixture(%{
          full_name: "employee3 full_name",
          job_title: "job_title_3",
          salary: 8_000_000,
          currency_id: currency1.id,
          country_id: country1.id
        })

      employee4 =
        employee_fixture(%{
          full_name: "employee4 full_name",
          job_title: "job_title_4",
          salary: 8_000_000,
          currency_id: currency2.id,
          country_id: country2.id
        })

      employee_list_by_country1 = Employees.get_employees_by_country(country1.id)
      employee_list_by_country2 = Employees.get_employees_by_country(country2.id)

      assert length(employee_list_by_country1) == 3
      assert length(employee_list_by_country2) == 1
    end

    test "get_employees_by_job_title/1 returns a list of employees filtered by job_title" do
      currency3 =
        currency_fixture(%{
          name: "currency3",
          code: "currency3 code",
          symbol: "currency3 symbol"
        })

      country3 =
        country_fixture(%{
          name: "country3",
          code: "country3 code"
        })

      employee1 =
        employee_fixture(%{
          full_name: "employee1 fullname",
          job_title: "job_title_1",
          salary: 6_000_000,
          currency_id: currency3.id,
          country_id: country3.id
        })

      employee2 =
        employee_fixture(%{
          full_name: "employee2 full_name",
          job_title: "job_title_1",
          salary: 7_000_000,
          currency_id: currency3.id,
          country_id: country3.id
        })

      employee3 =
        employee_fixture(%{
          full_name: "employee3 full_name",
          job_title: "job_title_3",
          salary: 8_000_000,
          currency_id: currency3.id,
          country_id: country3.id
        })

      employee4 =
        employee_fixture(%{
          full_name: "employee4 full_name",
          job_title: "job_title_4",
          salary: 8_000_000,
          currency_id: currency3.id,
          country_id: country3.id
        })

      employee_list_by_job_title_1 = Employees.get_employees_by_job_title("job_title_1")
      employee_list_by_job_title_2 = Employees.get_employees_by_job_title("job_title_2")
      employee_list_by_job_title_3 = Employees.get_employees_by_job_title("job_title_3")
      employee_list_by_job_title_4 = Employees.get_employees_by_job_title("job_title_4")

      assert length(employee_list_by_job_title_1) == 2
      assert length(employee_list_by_job_title_2) == 0
      assert length(employee_list_by_job_title_3) == 1
      assert length(employee_list_by_job_title_4) == 1
    end
  end
end
