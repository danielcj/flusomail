defmodule Flusomail.Organizations.Organization do
  use Flusomail, :schema

  schema "organizations" do
    field :name, :string
    field :slug, :string
    field :settings, :map
    field :billing_email, :string
    field :plan, :string
    field :status, :string

    # Keep the original user_id as the creator/owner
    belongs_to :user, Flusomail.Accounts.User

    # Many-to-many relationship with users through organization_users
    has_many :organization_users, Flusomail.Organizations.OrganizationUser
    has_many :users, through: [:organization_users, :user]

    # Domains belong to organizations
    has_many :domains, Flusomail.Organizations.Domain

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs, user_scope) do
    organization
    |> cast(attrs, [:name, :slug, :settings, :billing_email, :plan, :status])
    |> validate_required([:name, :billing_email, :plan, :status])
    |> put_change(:user_id, user_scope.user.id)
    |> generate_slug_if_empty()
    |> validate_format(:slug, ~r/^[a-z0-9-]+$/,
      message: "must contain only lowercase letters, numbers, and hyphens"
    )
    |> unique_constraint(:slug)
  end

  defp generate_slug_if_empty(changeset) do
    case get_change(changeset, :slug) do
      nil ->
        name = get_change(changeset, :name) || get_field(changeset, :name)

        if name do
          slug =
            name
            |> String.downcase()
            |> String.replace(~r/[^a-z0-9]/, "-")
            |> String.replace(~r/-+/, "-")
            |> String.trim("-")

          put_change(changeset, :slug, slug)
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
