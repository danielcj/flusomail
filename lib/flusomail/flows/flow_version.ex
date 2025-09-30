defmodule Flusomail.Flows.FlowVersion do
  use Ecto.Schema
  import Ecto.Changeset

  alias Flusomail.Flows.Flow
  alias Flusomail.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "flow_versions" do
    field :version_number, :integer
    field :graph, :map
    field :change_description, :string

    belongs_to :flow, Flow
    belongs_to :changed_by, User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc false
  def changeset(flow_version, attrs) do
    flow_version
    |> cast(attrs, [:flow_id, :version_number, :graph, :change_description, :changed_by_id])
    |> validate_required([:flow_id, :version_number, :graph])
    |> unique_constraint([:flow_id, :version_number])
    |> foreign_key_constraint(:flow_id)
    |> foreign_key_constraint(:changed_by_id)
  end
end