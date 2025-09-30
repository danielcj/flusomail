defmodule Flusomail.Flows.Journey do
  use Ecto.Schema
  import Ecto.Changeset

  alias Flusomail.Flows.{Flow, JourneyStep}
  alias Flusomail.Contacts.Contact

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "journeys" do
    field :flow_version, :integer
    field :state, :string, default: "active"
    field :current_node_id, :string

    # Journey data/context that nodes can read/write
    field :context, :map, default: %{}

    # Entry information
    field :entry_source, :string
    field :entry_metadata, :map

    # Timing
    field :started_at, :utc_datetime
    field :last_activity_at, :utc_datetime
    field :completed_at, :utc_datetime
    field :scheduled_resume_at, :utc_datetime

    # Exit tracking
    field :exit_reason, :string
    field :exit_node_id, :string

    belongs_to :flow, Flow
    belongs_to :contact, Contact
    has_many :steps, JourneyStep

    timestamps(type: :utc_datetime)
  end

  @states ["active", "waiting", "completed", "exited", "failed"]

  @doc """
  Returns the list of available journey states.
  """
  def states, do: @states

  @doc false
  def changeset(journey, attrs) do
    journey
    |> cast(attrs, [
      :flow_id,
      :flow_version,
      :contact_id,
      :state,
      :current_node_id,
      :context,
      :entry_source,
      :entry_metadata,
      :started_at,
      :last_activity_at,
      :completed_at,
      :scheduled_resume_at,
      :exit_reason,
      :exit_node_id
    ])
    |> validate_required([:flow_id, :flow_version, :contact_id, :state])
    |> validate_inclusion(:state, @states)
    |> foreign_key_constraint(:flow_id)
    |> foreign_key_constraint(:contact_id)
  end

  @doc """
  Changeset for creating a new journey.
  """
  def create_changeset(journey, attrs) do
    journey
    |> changeset(attrs)
    |> put_change(:started_at, DateTime.utc_now() |> DateTime.truncate(:second))
    |> put_change(:last_activity_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end

  @doc """
  Changeset for updating journey state.
  """
  def state_changeset(journey, state) when state in @states do
    journey
    |> change(%{state: state})
    |> put_change(:last_activity_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end

  @doc """
  Changeset for advancing to next node.
  """
  def advance_changeset(journey, next_node_id) do
    journey
    |> change(%{current_node_id: next_node_id})
    |> put_change(:last_activity_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end

  @doc """
  Changeset for scheduling a wait.
  """
  def schedule_changeset(journey, resume_at) do
    journey
    |> change(%{
      state: "waiting",
      scheduled_resume_at: resume_at
    })
    |> put_change(:last_activity_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end

  @doc """
  Changeset for completing a journey.
  """
  def complete_changeset(journey, exit_reason) do
    journey
    |> change(%{
      state: "completed",
      completed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      exit_reason: exit_reason
    })
    |> put_change(:last_activity_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end
end