defmodule Flusomail.Repo.Migrations.CreateDomains do
  use Ecto.Migration

  def change do
    create table(:domains, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :status, :string
      add :verified_at, :utc_datetime
      add :dkim_verified, :boolean, default: false, null: false
      add :spf_verified, :boolean, default: false, null: false
      add :dmarc_verified, :boolean, default: false, null: false
      add :ses_identity_arn, :string
      add :ses_verification_token, :string
      add :organization_id, references(:organizations, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:domains, [:organization_id])
    create unique_index(:domains, [:name, :organization_id])
  end
end
