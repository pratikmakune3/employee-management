defmodule Exercise.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :full_name, :string
      add :job_title, :string
      add :salary, :decimal
      add :country_id, references(:countries, on_delete: :nothing)
      add :currency_id, references(:currencies, on_delete: :nothing)

      timestamps()
    end

    create index(:employees, [:country_id])
    create index(:employees, [:currency_id])
  end
end
