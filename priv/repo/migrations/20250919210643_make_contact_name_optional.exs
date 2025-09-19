defmodule Flusomail.Repo.Migrations.MakeContactNameOptional do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      modify :name, :string, null: true
    end
  end
end
