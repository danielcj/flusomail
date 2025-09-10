defmodule Flusomail.Organizations.OrganizationUser do
  use Flusomail, :schema

  schema "organization_users" do
    field :role, :string
    field :status, :string
    field :invited_at, :utc_datetime
    field :joined_at, :utc_datetime
    
    belongs_to :organization, Flusomail.Organizations.Organization
    belongs_to :user, Flusomail.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization_user, attrs) do
    organization_user
    |> cast(attrs, [:role, :status, :invited_at, :joined_at, :organization_id, :user_id])
    |> validate_required([:role, :status, :organization_id, :user_id])
    |> validate_inclusion(:role, ["admin", "member", "viewer"])
    |> validate_inclusion(:status, ["active", "invited", "inactive"])
    |> unique_constraint([:organization_id, :user_id])
  end
end
