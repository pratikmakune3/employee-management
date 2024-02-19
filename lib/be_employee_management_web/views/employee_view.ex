defmodule ExerciseWeb.EmployeeView do
  use ExerciseWeb, :view
  alias ExerciseWeb.EmployeeView

  def render("index.json", %{employees: employees}) do
    %{data: render_many(employees, EmployeeView, "employee.json")}
  end

  def render("show.json", %{employee: employee}) do
    %{data: render_one(employee, EmployeeView, "employee.json")}
  end

  def render("employee.json", %{employee: employee}) do
    %{
      id: employee.id,
      full_name: employee.full_name,
      job_title: employee.job_title,
      salary: employee.salary,
      country_id: employee.country_id,
      currency_id: employee.currency_id
    }
  end

  def render("salary_metrics_by_country.json", %{salary_metrics: salary_metrics}) do
    %{
      data: %{
        min_salary: salary_metrics.min_salary,
        max_salary: salary_metrics.max_salary,
        avg_salary: salary_metrics.avg_salary
      }
    }
  end

  def render("salary_metrics_by_job_title.json", %{salary_metrics: salary_metrics}) do
    %{
      data: %{
        avg_salary: salary_metrics.avg_salary
      }
    }
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end
end
