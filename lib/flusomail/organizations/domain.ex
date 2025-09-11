defmodule Flusomail.Organizations.Domain do
  use Flusomail, :schema

  schema "domains" do
    field :name, :string
    field :status, :string
    field :verified_at, :utc_datetime
    field :dkim_verified, :boolean, default: false
    field :spf_verified, :boolean, default: false
    field :dmarc_verified, :boolean, default: false
    field :ses_identity_arn, :string
    field :ses_verification_token, :string

    belongs_to :organization, Flusomail.Organizations.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(domain, attrs, organization) do
    domain
    |> cast(attrs, [
      :name,
      :status,
      :dkim_verified,
      :spf_verified,
      :dmarc_verified,
      :ses_identity_arn,
      :ses_verification_token
    ])
    |> put_change(:organization_id, organization.id)
    |> put_change(:status, attrs[:status] || "pending")
    |> validate_required([:name])
    |> validate_inclusion(:status, ["pending", "verified", "failed"])
    |> validate_format(
      :name,
      ~r/^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$/,
      message: "must be a valid domain name"
    )
    |> unique_constraint([:name, :organization_id])
  end
end
