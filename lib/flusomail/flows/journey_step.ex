defmodule Flusomail.Flows.JourneyStep do
  use Ecto.Schema
  import Ecto.Changeset

  alias Flusomail.Flows.Journey

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "journey_steps" do
    field :node_id, :string
    field :node_type, :string
    field :status, :string
    field :input, :map
    field :output, :map
    field :error, :string
    field :executed_at, :utc_datetime
    field :duration_ms, :integer

    belongs_to :journey, Journey
  end

  @statuses ["success", "failure", "skipped", "pending"]

  @doc """
  Returns the list of available step statuses.
  """
  def statuses, do: @statuses

  @doc false
  def changeset(journey_step, attrs) do
    journey_step
    |> cast(attrs, [
      :journey_id,
      :node_id,
      :node_type,
      :status,
      :input,
      :output,
      :error,
      :executed_at,
      :duration_ms
    ])
    |> validate_required([:journey_id, :node_id, :node_type, :status])
    |> validate_inclusion(:status, @statuses)
    |> foreign_key_constraint(:journey_id)
  end

  @doc """
  Changeset for creating a journey step with execution time.
  """
  def create_changeset(journey_step, attrs) do
    journey_step
    |> changeset(attrs)
    |> put_change(:executed_at, DateTime.utc_now() |> DateTime.truncate(:second))
  end

  @doc """
  Changeset for a successful step execution.
  """
  def success_changeset(journey_step, attrs) do
    attrs = Map.put(attrs, :status, "success")
    create_changeset(journey_step, attrs)
  end

  @doc """
  Changeset for a failed step execution.
  """
  def failure_changeset(journey_step, attrs, error) do
    attrs =
      attrs
      |> Map.put(:status, "failure")
      |> Map.put(:error, error)

    create_changeset(journey_step, attrs)
  end
end