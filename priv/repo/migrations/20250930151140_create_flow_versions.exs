defmodule Flusomail.Repo.Migrations.CreateFlowVersions do
  use Ecto.Migration

  def change do
    create table(:flow_versions, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :flow_id, references(:flows, type: :uuid, on_delete: :delete_all), null: false
      add :version_number, :integer, null: false
      add :graph, :jsonb, null: false
      add :changed_by_id, references(:users, type: :uuid, on_delete: :nilify_all)
      add :change_description, :text

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create unique_index(:flow_versions, [:flow_id, :version_number])
    create index(:flow_versions, [:flow_id])
  end
end
