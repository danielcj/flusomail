defmodule Flusomail.Repo.Migrations.CreateJourneys do
  use Ecto.Migration

  def change do
    create table(:journeys, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :flow_id, references(:flows, type: :uuid, on_delete: :delete_all), null: false
      add :flow_version, :integer, null: false
      add :contact_id, references(:contacts, type: :uuid, on_delete: :delete_all), null: false

      add :state, :string, null: false, default: "active"
      add :current_node_id, :string

      # Journey data/context that nodes can read/write
      add :context, :jsonb, default: fragment("'{}'::jsonb")

      # Entry information
      add :entry_source, :string
      add :entry_metadata, :jsonb

      # Timing
      add :started_at, :utc_datetime, null: false, default: fragment("NOW()")
      add :last_activity_at, :utc_datetime, null: false, default: fragment("NOW()")
      add :completed_at, :utc_datetime
      add :scheduled_resume_at, :utc_datetime

      # Exit tracking
      add :exit_reason, :string
      add :exit_node_id, :string

      timestamps(type: :utc_datetime)
    end

    create index(:journeys, [:flow_id])
    create index(:journeys, [:contact_id])
    create index(:journeys, [:state])
    create index(:journeys, [:scheduled_resume_at], where: "state = 'waiting'")
  end
end
