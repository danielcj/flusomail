defmodule Flusomail.Repo.Migrations.CreateTemplates do
  use Ecto.Migration

  def change do
    create table(:templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :subject, :string, null: false
      add :html_content, :text, null: false
      add :text_content, :text
      add :category, :string, null: false
      add :description, :text
      add :variables, :map, default: %{}
      add :is_active, :boolean, default: true
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all), null: false
      add :created_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:templates, [:organization_id])
    create index(:templates, [:category])
    create index(:templates, [:is_active])
    create index(:templates, [:created_by_id])
    create unique_index(:templates, [:organization_id, :name])
  end
end
