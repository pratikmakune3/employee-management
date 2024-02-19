defmodule ExerciseWeb.EmployeeController do
  alias Exercise.Countries
  use ExerciseWeb, :controller

  alias Exercise.Employees
  alias Exercise.Employees.Employee

  import Exercise.Services.Cache

  action_fallback ExerciseWeb.FallbackController

  def index(conn, _params) do
    employees = Employees.list_employees()
    render(conn, :index, employees: employees)
  end

  def create(conn, %{"employee" => employee_params}) do
    with {:ok, %Employee{} = employee} <- Employees.create_employee(employee_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/employees/#{employee}")
      |> render(:show, employee: employee)
    end
  end

  def show(conn, %{"id" => id}) do
    employee = Employees.get_employee!(id)
    render(conn, :show, employee: employee)
  end

  def update(conn, %{"id" => id, "employee" => employee_params}) do
    employee = Employees.get_employee!(id)

    with {:ok, %Employee{} = employee} <- Employees.update_employee(employee, employee_params) do
      render(conn, :show, employee: employee)
    end
  end

  def delete(conn, %{"id" => id}) do
    employee = Employees.get_employee!(id)

    with {:ok, %Employee{}} <- Employees.delete_employee(employee) do
      send_resp(conn, :no_content, "")
    end
  end

  def salary_metrics(conn, %{"country_code" => country_code}) do
    try do
      cached_response = get_from_cache(country_code)

      case cached_response do
        {:ok, response} ->
          IO.puts("Cache Hit!!!")

          render(conn, :salary_metrics_by_country, salary_metrics: response)

        {:error, nil} ->
          IO.puts("Cache Miss***")
          country = Countries.get_country_by_code!(country_code)

          salaries =
            Employees.get_employees_by_country(country.id)
            |> Enum.map(&Decimal.to_float(&1.salary))

          case salaries do
            [] ->
              render(conn, "error.json", %{error: "No employees found"})

            _salaries ->
              min_salary = Enum.min(salaries)
              max_salary = Enum.max(salaries)
              avg_salary = Enum.reduce(salaries, 0, &(&1 + &2)) / length(salaries)

              response = %{
                min_salary: min_salary,
                max_salary: max_salary,
                avg_salary: avg_salary
              }

              put_in_cache(country_code, response, 3600)

              render(conn, :salary_metrics_by_country, salary_metrics: response)
          end
      end
    catch
      :error, %Ecto.NoResultsError{} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", %{error: "Country not found"})

      :error, _error ->
        render(conn, "error.json", %{error: "Internal server error"})
    end
  end

  def salary_metrics(conn, %{"job_title" => job_title}) do
    try do
      cached_response = get_from_cache(job_title)

      case cached_response do
        {:ok, response} ->
          IO.puts("Cache Hit!!!")
          IO.inspect(response)

          render(conn, :salary_metrics_by_job_title, salary_metrics: response)

        {:error, nil} ->
          IO.puts("Cache Miss***")

          salaries =
            Employees.get_employees_by_job_title(job_title)
            |> Enum.map(&Decimal.to_float(&1.salary))

          case salaries do
            [] ->
              render(conn, "error.json", %{error: "No employees found"})

            _salaries ->
              avg_salary = Enum.reduce(salaries, 0, &(&1 + &2)) / length(salaries)

              response = %{avg_salary: avg_salary}

              put_in_cache(job_title, response, 3600)

              render(conn, :salary_metrics_by_job_title, salary_metrics: response)
          end
      end
    catch
      :error, _error ->
        render(conn, "error.json", %{error: "Internal server error"})
    end
  end
end
