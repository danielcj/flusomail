defmodule Flusomail.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false

      add :organization_id, references(:organizations, on_delete: :delete_all, type: :binary_id),
        null: true

      add :created_by_id, references(:users, on_delete: :nilify_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contacts, [:organization_id])
    create index(:contacts, [:created_by_id])
    create unique_index(:contacts, [:organization_id, :email])
    create index(:contacts, [:email])
  end
end
