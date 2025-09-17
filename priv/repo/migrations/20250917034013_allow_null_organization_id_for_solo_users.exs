defmodule Flusomail.Repo.Migrations.AllowNullOrganizationIdForSoloUsers do
  use Ecto.Migration

  def change do
    alter table(:flows) do
      modify :organization_id, :binary_id, null: true
    end
  end
end
