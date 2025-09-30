defmodule Flusomail.Flows do
  @moduledoc """
  The Flows context for managing email marketing flows (campaigns and automations).
  """

  import Ecto.Query, warn: false
  alias Flusomail.Repo

  alias Flusomail.Flows.{Flow, FlowVersion, Journey, JourneyStep}

  @doc """
  Returns the list of flows for an organization.

  ## Examples

      iex> list_flows(organization_id)
      [%Flow{}, ...]

  """
  def list_flows(organization_id) do
    query =
      if is_nil(organization_id) do
        Flow |> where([f], is_nil(f.organization_id))
      else
        Flow |> where([f], f.organization_id == ^organization_id)
      end

    query
    |> order_by([f], desc: f.updated_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of active flows for an organization.
  """
  def list_active_flows(organization_id) do
    Flow
    |> where([f], f.organization_id == ^organization_id and f.state == "active")
    |> Repo.all()
  end

  @doc """
  Gets a single flow.

  Raises `Ecto.NoResultsError` if the Flow does not exist.

  ## Examples

      iex> get_flow!(123)
      %Flow{}

      iex> get_flow!(456)
      ** (Ecto.NoResultsError)

  """
  def get_flow!(id), do: Repo.get!(Flow, id)

  @doc """
  Gets a single flow for an organization.
  """
  def get_flow!(organization_id, id) do
    query =
      if is_nil(organization_id) do
        Flow |> where([f], f.id == ^id and is_nil(f.organization_id))
      else
        Flow |> where([f], f.id == ^id and f.organization_id == ^organization_id)
      end

    Repo.one!(query)
  end

  @doc """
  Creates a flow.

  ## Examples

      iex> create_flow(%{field: value})
      {:ok, %Flow{}}

      iex> create_flow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_flow(attrs \\ %{}) do
    %Flow{}
    |> Flow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a flow.

  ## Examples

      iex> update_flow(flow, %{field: new_value})
      {:ok, %Flow{}}

      iex> update_flow(flow, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_flow(%Flow{} = flow, attrs) do
    flow
    |> Flow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates only the graph portion of a flow.
  """
  def update_flow_graph(%Flow{} = flow, attrs) do
    flow
    |> Flow.graph_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Activates a flow, making it start processing triggers.
  """
  def activate_flow(%Flow{state: "draft"} = flow) do
    flow
    |> Flow.activate_changeset()
    |> Repo.update()
  end

  def activate_flow(%Flow{state: "paused"} = flow) do
    flow
    |> Flow.activate_changeset()
    |> Repo.update()
  end

  @doc """
  Pauses an active flow.
  """
  def pause_flow(%Flow{state: "active"} = flow) do
    flow
    |> Flow.pause_changeset()
    |> Repo.update()
  end

  @doc """
  Archives a flow.
  """
  def archive_flow(%Flow{} = flow) do
    flow
    |> Flow.changeset(%{state: "archived"})
    |> Repo.update()
  end

  @doc """
  Deletes a flow.

  ## Examples

      iex> delete_flow(flow)
      {:ok, %Flow{}}

      iex> delete_flow(flow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_flow(%Flow{} = flow) do
    Repo.delete(flow)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking flow changes.

  ## Examples

      iex> change_flow(flow)
      %Ecto.Changeset{data: %Flow{}}

  """
  def change_flow(%Flow{} = flow, attrs \\ %{}) do
    Flow.changeset(flow, attrs)
  end

  @doc """
  Duplicates a flow with a new name.
  """
  def duplicate_flow(%Flow{} = flow, new_name) do
    %Flow{}
    |> Flow.changeset(%{
      name: new_name,
      description: flow.description,
      flow_type: flow.flow_type,
      graph: flow.graph,
      canvas_state: flow.canvas_state,
      settings: flow.settings,
      organization_id: flow.organization_id,
      created_by_id: flow.created_by_id,
      state: "draft"
    })
    |> Repo.insert()
  end

  # Journey management functions

  @doc """
  Returns the list of journeys for a flow.
  """
  def list_journeys(flow_id) do
    Journey
    |> where([j], j.flow_id == ^flow_id)
    |> order_by([j], desc: j.started_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of active journeys for a flow.
  """
  def list_active_journeys(flow_id) do
    Journey
    |> where([j], j.flow_id == ^flow_id and j.state in ["active", "waiting"])
    |> Repo.all()
  end

  @doc """
  Returns the list of journeys for a contact.
  """
  def list_contact_journeys(contact_id) do
    Journey
    |> where([j], j.contact_id == ^contact_id)
    |> order_by([j], desc: j.started_at)
    |> Repo.all()
  end

  @doc """
  Gets a single journey.
  """
  def get_journey!(id), do: Repo.get!(Journey, id)

  @doc """
  Gets a journey with preloaded associations.
  """
  def get_journey_with_steps!(id) do
    Journey
    |> where([j], j.id == ^id)
    |> preload([:flow, :contact, :steps])
    |> Repo.one!()
  end

  @doc """
  Creates a journey for a contact in a flow.
  """
  def create_journey(attrs \\ %{}) do
    %Journey{}
    |> Journey.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a journey.
  """
  def update_journey(%Journey{} = journey, attrs) do
    journey
    |> Journey.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Advances a journey to the next node.
  """
  def advance_journey(%Journey{} = journey, next_node_id) do
    journey
    |> Journey.advance_changeset(next_node_id)
    |> Repo.update()
  end

  @doc """
  Schedules a journey to resume at a specific time (for wait nodes).
  """
  def schedule_journey(%Journey{} = journey, resume_at) do
    journey
    |> Journey.schedule_changeset(resume_at)
    |> Repo.update()
  end

  @doc """
  Completes a journey with an exit reason.
  """
  def complete_journey(%Journey{} = journey, exit_reason) do
    journey
    |> Journey.complete_changeset(exit_reason)
    |> Repo.update()
  end

  @doc """
  Returns journeys that are scheduled to resume.
  """
  def list_scheduled_journeys do
    now = DateTime.utc_now()

    Journey
    |> where([j], j.state == "waiting")
    |> where([j], j.scheduled_resume_at <= ^now)
    |> Repo.all()
  end

  # Journey step functions

  @doc """
  Creates a journey step.
  """
  def create_journey_step(attrs \\ %{}) do
    %JourneyStep{}
    |> JourneyStep.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a successful journey step.
  """
  def create_success_step(attrs) do
    %JourneyStep{}
    |> JourneyStep.success_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a failed journey step.
  """
  def create_failure_step(attrs, error) do
    %JourneyStep{}
    |> JourneyStep.failure_changeset(attrs, error)
    |> Repo.insert()
  end

  @doc """
  Returns the list of steps for a journey.
  """
  def list_journey_steps(journey_id) do
    JourneyStep
    |> where([s], s.journey_id == ^journey_id)
    |> order_by([s], asc: s.executed_at)
    |> Repo.all()
  end

  # Flow version functions

  @doc """
  Creates a flow version snapshot.
  """
  def create_flow_version(%Flow{} = flow, attrs \\ %{}) do
    # Get the next version number
    version_number = get_next_version_number(flow.id)

    %FlowVersion{}
    |> FlowVersion.changeset(
      Map.merge(attrs, %{
        flow_id: flow.id,
        version_number: version_number,
        graph: flow.graph
      })
    )
    |> Repo.insert()
  end

  @doc """
  Returns all versions for a flow.
  """
  def list_flow_versions(flow_id) do
    FlowVersion
    |> where([v], v.flow_id == ^flow_id)
    |> order_by([v], desc: v.version_number)
    |> Repo.all()
  end

  @doc """
  Gets a specific flow version.
  """
  def get_flow_version!(flow_id, version_number) do
    FlowVersion
    |> where([v], v.flow_id == ^flow_id and v.version_number == ^version_number)
    |> Repo.one!()
  end

  defp get_next_version_number(flow_id) do
    query =
      FlowVersion
      |> where([v], v.flow_id == ^flow_id)
      |> select([v], max(v.version_number))

    case Repo.one(query) do
      nil -> 1
      max_version -> max_version + 1
    end
  end
end
