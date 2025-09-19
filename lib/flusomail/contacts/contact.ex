defmodule Flusomail.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  alias Flusomail.Organizations.Organization
  alias Flusomail.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :name, :string
    field :email, :string

    belongs_to :organization, Organization
    belongs_to :created_by, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :email, :organization_id, :created_by_id])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/, message: "must be a valid email")
    |> validate_length(:name, min: 1, max: 255)
    |> validate_length(:email, max: 255)
    |> unique_constraint([:organization_id, :email],
      message: "email already exists in this organization"
    )
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:created_by_id)
  end
end
