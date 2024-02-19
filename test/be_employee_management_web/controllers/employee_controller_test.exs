defmodule ExerciseWeb.EmployeeControllerTest do
  use ExerciseWeb.ConnCase

  import Exercise.EmployeesFixtures

  alias Exercise.Employees.Employee

  @create_attrs %{
    full_name: "some full_name",
    job_title: "some job_title",
    salary: "120.5"
  }
  @update_attrs %{
    full_name: "some updated full_name",
    job_title: "some updated job_title",
    salary: "456.7"
  }
  @invalid_attrs %{full_name: nil, job_title: nil, salary: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all employees", %{conn: conn} do
      conn = get(conn, ~p"/api/employees")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create employee" do
    test "renders employee when data is valid", %{conn: conn} do
      # Create currency
      conn =
        post(conn, Routes.currency_path(conn, :create),
          currency: %{
            code: "some code",
            name: "some name",
            symbol: "some symbol"
          }
        )

      currency_id = Map.get(json_response(conn, 201)["data"], "id")

      # Create country
      conn =
        post(conn, Routes.country_path(conn, :create),
          country: %{
            code: "some code",
            name: "some name"
          }
        )

      country_id = Map.get(json_response(conn, 201)["data"], "id")

      # Create employee
      conn =
        post(conn, ~p"/api/employees",
          employee: %{
            full_name: "some full_name",
            job_title: "some job_title",
            salary: "120.5",
            currency_id: currency_id,
            country_id: country_id
          }
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/employees/#{id}")

      expected = %{
        "id" => id,
        "full_name" => "some full_name",
        "job_title" => "some job_title",
        "salary" => "120.5",
        "currency_id" => currency_id,
        "country_id" => country_id
      }

      assert expected = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/employees", employee: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update employee" do
    setup [:create_employee]

    test "renders employee when data is valid", %{
      conn: conn,
      employee: %Employee{id: id} = employee
    } do
      conn = put(conn, ~p"/api/employees/#{employee}", employee: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/employees/#{id}")

      assert %{
               "id" => ^id,
               "full_name" => "some updated full_name",
               "job_title" => "some updated job_title",
               "salary" => "456.7"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, employee: employee} do
      conn = put(conn, ~p"/api/employees/#{employee}", employee: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete employee" do
    setup [:create_employee]

    test "deletes chosen employee", %{conn: conn, employee: employee} do
      conn = delete(conn, ~p"/api/employees/#{employee}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/employees/#{employee}")
      end
    end
  end

  describe "get salary metrics by country" do
    test "renders salary metrics when country is found", %{conn: conn} do
      # Create currency
      conn =
        post(conn, Routes.currency_path(conn, :create),
          currency: %{
            code: "currency1 code",
            name: "currency1",
            symbol: "currency1 symbol"
          }
        )

      currency_id = Map.get(json_response(conn, 201)["data"], "id")
      # Create country
      conn =
        post(conn, Routes.country_path(conn, :create),
          country: %{
            code: "country1 code",
            name: "country1"
          }
        )

      country_id = Map.get(json_response(conn, 201)["data"], "id")
      country_code = Map.get(json_response(conn, 201)["data"], "code")

      # Create employees for the country
      conn =
        post(conn, ~p"/api/employees",
          employee: %{
            full_name: "test full_name 1",
            job_title: "test job_title 1",
            salary: 20000.30,
            currency_id: currency_id,
            country_id: country_id
          }
        )

      conn =
        post(conn, ~p"/api/employees",
          employee: %{
            full_name: "test full_name 2",
            job_title: "test job_title 2",
            salary: 1200.80,
            currency_id: currency_id,
            country_id: country_id
          }
        )

      conn = get(conn, "/api/employees/salary-metrics?country_code=#{country_code}")

      response = json_response(conn, 200)
      assert Map.has_key?(response, "data")
      assert Map.has_key?(response["data"], "min_salary")
      assert Map.has_key?(response["data"], "max_salary")
      assert Map.has_key?(response["data"], "avg_salary")
    end

    test "renders error when country is not found", %{conn: conn} do
      conn = get(conn, "/api/employees/salary-metrics?country_code=some random country code}")

      assert conn.status == 422

      response = json_response(conn, 422)
      assert Map.has_key?(response, "error")
      assert response["error"] == "Country not found"
    end

    test "renders error when no employees found with given country code", %{conn: conn} do
      # Create country but don't attach it to any employee
      conn =
        post(conn, Routes.country_path(conn, :create),
          country: %{
            code: "country123",
            name: "country123"
          }
        )

      country_code = Map.get(json_response(conn, 201)["data"], "code")

      conn = get(conn, "/api/employees/salary-metrics?country_code=#{country_code}")

      assert conn.status == 200

      response = json_response(conn, 200)
      assert Map.has_key?(response, "error")
      assert response["error"] == "No employees found"
    end
  end

  describe "get salary metrics by job_title" do
    test "renders salary metrics when job_title is found", %{conn: conn} do
      # Create currency
      conn =
        post(conn, Routes.currency_path(conn, :create),
          currency: %{
            code: "currency2 code",
            name: "currency2",
            symbol: "currency2 symbol"
          }
        )

      currency_id = Map.get(json_response(conn, 201)["data"], "id")

      # Create country
      conn =
        post(conn, Routes.country_path(conn, :create),
          country: %{
            code: "country2 code",
            name: "country2"
          }
        )

      country_id = Map.get(json_response(conn, 201)["data"], "id")
      country_code = Map.get(json_response(conn, 201)["data"], "code")

      conn =
        post(conn, ~p"/api/employees",
          employee: %{
            full_name: "test1 full_name 1",
            job_title: "job_title_1",
            salary: 20000.30,
            currency_id: currency_id,
            country_id: country_id
          }
        )

      conn =
        post(conn, ~p"/api/employees",
          employee: %{
            full_name: "test1 full_name 2",
            job_title: "job_title_2",
            salary: 1200.80,
            currency_id: currency_id,
            country_id: country_id
          }
        )

      conn = get(conn, "/api/employees/salary-metrics?job_title=job_title_1")

      response = json_response(conn, 200)
      assert Map.has_key?(response, "data")
      assert Map.has_key?(response["data"], "avg_salary")
    end

    test "renders error when employee is not found with given job_title", %{conn: conn} do
      conn = get(conn, "/api/employees/salary-metrics?job_title=random_job_title")

      assert conn.status == 200

      response = json_response(conn, 200)
      assert Map.has_key?(response, "error")
      assert response["error"] == "No employees found"
    end
  end

  defp create_employee(_) do
    employee = employee_fixture()
    %{employee: employee}
  end
end
