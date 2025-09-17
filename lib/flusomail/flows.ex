defmodule Flusomail.Flows do
  @moduledoc """
  The Flows context for managing email marketing flows (campaigns and automations).
  """

  import Ecto.Query, warn: false
  alias Flusomail.Repo

  alias Flusomail.Flows.Flow

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
end
