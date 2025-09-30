defmodule Flusomail.Repo.Migrations.CreateJourneySteps do
  use Ecto.Migration

  def change do
    create table(:journey_steps, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :journey_id, references(:journeys, type: :uuid, on_delete: :delete_all), null: false
      add :node_id, :string, null: false
      add :node_type, :string, null: false

      # Execution details
      add :status, :string, null: false
      add :input, :jsonb
      add :output, :jsonb
      add :error, :text

      add :executed_at, :utc_datetime, null: false, default: fragment("NOW()")
      add :duration_ms, :integer
    end

    create index(:journey_steps, [:journey_id])
    create index(:journey_steps, [:executed_at])
  end
end
