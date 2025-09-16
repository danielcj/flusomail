defmodule Flusomail.Repo.Migrations.CreateFlows do
  use Ecto.Migration

  def change do
    create table(:flows, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :state, :string, null: false, default: "draft"
      add :flow_type, :string, null: false, default: "automation"
      add :graph, :map, null: false, default: %{"nodes" => [], "edges" => []}
      add :canvas_state, :map, default: %{"zoom" => 1, "pan" => %{"x" => 0, "y" => 0}}
      add :settings, :map, default: %{}
      add :activated_at, :utc_datetime
      add :paused_at, :utc_datetime
      add :completed_at, :utc_datetime

      add :stats, :map,
        default: %{"total_entered" => 0, "currently_active" => 0, "completed" => 0}

      add :organization_id, references(:organizations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :created_by_id, references(:users, on_delete: :nilify_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:flows, [:organization_id])
    create index(:flows, [:created_by_id])
    create index(:flows, [:state])
    create unique_index(:flows, [:organization_id, :name])
  end
end
