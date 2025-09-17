defmodule Flusomail.Flows.Flow do
  use Ecto.Schema
  import Ecto.Changeset

  alias Flusomail.Organizations.Organization
  alias Flusomail.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "flows" do
    field :name, :string
    field :description, :string
    field :state, :string, default: "draft"
    field :flow_type, :string, default: "automation"
    field :graph, :map, default: %{"nodes" => [], "edges" => []}
    field :canvas_state, :map, default: %{"zoom" => 1, "pan" => %{"x" => 0, "y" => 0}}
    field :settings, :map, default: %{}
    field :activated_at, :utc_datetime
    field :paused_at, :utc_datetime
    field :completed_at, :utc_datetime

    field :stats, :map,
      default: %{"total_entered" => 0, "currently_active" => 0, "completed" => 0}

    belongs_to :organization, Organization
    belongs_to :created_by, User

    timestamps(type: :utc_datetime)
  end

  @states ["draft", "active", "paused", "completed", "archived"]
  @flow_types ["automation", "campaign", "transactional"]

  @doc """
  Returns the list of available flow states.
  """
  def states, do: @states

  @doc """
  Returns the list of available flow types.
  """
  def flow_types, do: @flow_types

  @doc false
  def changeset(flow, attrs) do
    flow
    |> cast(attrs, [
      :name,
      :description,
      :state,
      :flow_type,
      :graph,
      :canvas_state,
      :settings,
      :organization_id,
      :created_by_id
    ])
    |> validate_required([:name, :state, :flow_type, :graph])
    |> validate_inclusion(:state, @states)
    |> validate_inclusion(:flow_type, @flow_types)
    |> validate_length(:name, min: 1, max: 255)
    |> validate_change(:graph, &validate_graph/2)
    |> unique_constraint([:organization_id, :name])
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:created_by_id)
  end

  @doc """
  Changeset for updating flow graph (nodes and edges).
  """
  def graph_changeset(flow, %{graph: _} = attrs) do
    flow
    |> cast(attrs, [:graph, :canvas_state])
    |> validate_change(:graph, &validate_graph/2)
  end

  @doc """
  Changeset for activating a flow.
  """
  def activate_changeset(flow) do
    flow
    |> change(%{state: "active", activated_at: DateTime.utc_now() |> DateTime.truncate(:second)})
    |> validate_graph_for_activation()
  end

  @doc """
  Changeset for pausing a flow.
  """
  def pause_changeset(flow) do
    flow
    |> change(%{state: "paused", paused_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end

  defp validate_graph(:graph, graph) when is_map(graph) do
    nodes = Map.get(graph, "nodes") || Map.get(graph, :nodes)
    edges = Map.get(graph, "edges") || Map.get(graph, :edges)

    cond do
      not is_list(nodes) ->
        [graph: "must contain a list of nodes"]

      not is_list(edges) ->
        [graph: "must contain a list of edges"]

      true ->
        []
    end
  end

  defp validate_graph(:graph, _), do: [graph: "must be a map with nodes and edges"]

  defp validate_graph_for_activation(changeset) do
    graph = get_field(changeset, :graph) || %{}
    nodes = Map.get(graph, "nodes") || Map.get(graph, :nodes) || []
    edges = Map.get(graph, "edges") || Map.get(graph, :edges) || []

    cond do
      Enum.empty?(nodes) ->
        add_error(changeset, :graph, "must have at least one node to activate")

      not has_trigger_node?(nodes) ->
        add_error(changeset, :graph, "must have at least one trigger node to activate")

      not all_nodes_connected?(nodes, edges) ->
        add_error(changeset, :graph, "all nodes must be connected")

      true ->
        changeset
    end
  end

  defp has_trigger_node?(nodes) do
    Enum.any?(nodes, fn node ->
      Map.get(node, "type") == "trigger" || Map.get(node, :type) == "trigger"
    end)
  end

  defp all_nodes_connected?(nodes, edges) do
    node_ids =
      MapSet.new(nodes, fn node ->
        Map.get(node, "id") || Map.get(node, :id)
      end)

    connected_ids =
      edges
      |> Enum.flat_map(fn edge ->
        source = Map.get(edge, "source") || Map.get(edge, :source)
        target = Map.get(edge, "target") || Map.get(edge, :target)
        [source, target]
      end)
      |> MapSet.new()

    MapSet.subset?(node_ids, connected_ids) or Enum.count(nodes) <= 1
  end
end
