defmodule Flusomail.Repo.Migrations.CreateOrganizationUsers do
  use Ecto.Migration

  def change do
    create table(:organization_users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :status, :string
      add :invited_at, :utc_datetime
      add :joined_at, :utc_datetime
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:organization_users, [:organization_id])
    create index(:organization_users, [:user_id])
    create unique_index(:organization_users, [:organization_id, :user_id])
  end
end
