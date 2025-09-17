defmodule FlusomailWeb.FlowLive.Canvas do
  use FlusomailWeb, :live_view

  alias Flusomail.Flows

  defp get_organization_id(scope) do
    case scope.organization do
      %{id: id} -> id
      nil -> nil
    end
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    flow = Flows.get_flow!(get_organization_id(socket.assigns.current_scope), id)

    {:ok,
     socket
     |> assign(:page_title, flow.name)
     |> assign(:flow, flow)
     |> assign(:selected_node, nil)
     |> assign(:show_node_palette, false)}
  end

  @impl true
  def handle_event("canvas_ready", _params, socket) do
    # Initialize the canvas with current flow data
    {:noreply,
     push_event(socket, "load_flow", %{
       graph: socket.assigns.flow.graph,
       canvas_state: socket.assigns.flow.canvas_state
     })}
  end

  def handle_event("node_added", %{"type" => type, "position" => position}, socket) do
    node_id = "node_#{System.unique_integer([:positive])}"

    new_node = %{
      "id" => node_id,
      "type" => type,
      "position" => position,
      "data" => default_node_data(type)
    }

    current_graph = socket.assigns.flow.graph
    updated_graph = Map.update(current_graph, "nodes", [new_node], &[new_node | &1])

    case Flows.update_flow_graph(socket.assigns.flow, %{graph: updated_graph}) do
      {:ok, updated_flow} ->
        {:noreply,
         socket
         |> assign(:flow, updated_flow)
         |> put_flash(:info, "Node added")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add node")}
    end
  end

  def handle_event("node_moved", %{"id" => node_id, "position" => position}, socket) do
    current_graph = socket.assigns.flow.graph
    nodes = Map.get(current_graph, "nodes", [])

    updated_nodes =
      Enum.map(nodes, fn node ->
        if node["id"] == node_id do
          Map.put(node, "position", position)
        else
          node
        end
      end)

    updated_graph = Map.put(current_graph, "nodes", updated_nodes)

    case Flows.update_flow_graph(socket.assigns.flow, %{graph: updated_graph}) do
      {:ok, updated_flow} ->
        {:noreply, assign(socket, :flow, updated_flow)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("edge_added", %{"source" => source, "target" => target}, socket) do
    edge_id = "edge_#{System.unique_integer([:positive])}"

    new_edge = %{
      "id" => edge_id,
      "source" => source,
      "target" => target,
      "type" => "default"
    }

    current_graph = socket.assigns.flow.graph
    updated_graph = Map.update(current_graph, "edges", [new_edge], &[new_edge | &1])

    case Flows.update_flow_graph(socket.assigns.flow, %{graph: updated_graph}) do
      {:ok, updated_flow} ->
        {:noreply,
         socket
         |> assign(:flow, updated_flow)
         |> put_flash(:info, "Connection created")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create connection")}
    end
  end

  def handle_event("node_selected", %{"id" => node_id}, socket) do
    {:noreply, assign(socket, :selected_node, node_id)}
  end

  def handle_event("node_deselected", _params, socket) do
    {:noreply, assign(socket, :selected_node, nil)}
  end

  def handle_event("toggle_node_palette", _params, socket) do
    {:noreply, assign(socket, :show_node_palette, !socket.assigns.show_node_palette)}
  end

  def handle_event("activate_flow", _params, socket) do
    case Flows.activate_flow(socket.assigns.flow) do
      {:ok, updated_flow} ->
        {:noreply,
         socket
         |> assign(:flow, updated_flow)
         |> put_flash(:info, "Flow activated successfully!")}

      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
        error_msg = errors |> Map.values() |> List.flatten() |> Enum.join(", ")

        {:noreply, put_flash(socket, :error, "Cannot activate flow: #{error_msg}")}
    end
  end

  def handle_event("pause_flow", _params, socket) do
    case Flows.pause_flow(socket.assigns.flow) do
      {:ok, updated_flow} ->
        {:noreply,
         socket
         |> assign(:flow, updated_flow)
         |> put_flash(:info, "Flow paused")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to pause flow")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="h-screen flex flex-col">
        <!-- Top Toolbar -->
        <div class="bg-base-100 border-b border-base-200 px-4 py-3 flex justify-between items-center">
          <div class="flex items-center gap-4">
            <.link navigate={~p"/flows"} class="btn btn-ghost btn-sm">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-4 w-4 mr-1"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M15 19l-7-7 7-7"
                />
              </svg>
              Back
            </.link>
            <div>
              <h1 class="text-lg font-semibold">{@flow.name}</h1>
              <div class="flex items-center gap-2 text-sm text-base-content/60">
                <span class={"badge badge-sm #{state_badge_class(@flow.state)}"}>
                  {@flow.state}
                </span>
                <span>{@flow.flow_type}</span>
              </div>
            </div>
          </div>

          <div class="flex items-center gap-2">
            <button
              phx-click="toggle_node_palette"
              class={[
                "btn btn-sm",
                if(@show_node_palette, do: "btn-primary", else: "btn-ghost")
              ]}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-4 w-4 mr-1"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 4v16m8-8H4"
                />
              </svg>
              Add Node
            </button>

            <%= if @flow.state == "draft" do %>
              <button phx-click="activate_flow" class="btn btn-sm btn-success">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-4 w-4 mr-1"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
                  />
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
                Activate
              </button>
            <% else %>
              <%= if @flow.state == "active" do %>
                <button phx-click="pause_flow" class="btn btn-sm btn-warning">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 mr-1"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                  Pause
                </button>
              <% end %>
            <% end %>

            <.link navigate={~p"/flows/#{@flow}/edit"} class="btn btn-sm btn-ghost">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-4 w-4 mr-1"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                />
              </svg>
              Settings
            </.link>
          </div>
        </div>

        <div class="flex-1 flex relative">
          <!-- Node Palette (Sidebar) -->
          <%= if @show_node_palette do %>
            <div class="w-64 bg-base-100 border-r border-base-200 p-4">
              <h3 class="font-semibold mb-4">Add Nodes</h3>

              <div class="space-y-4">
                <div>
                  <h4 class="text-sm font-medium text-base-content/60 mb-2">Triggers</h4>
                  <div class="space-y-2">
                    <div
                      class="p-3 bg-success/10 border border-success/20 rounded-lg cursor-pointer hover:bg-success/20 transition-colors"
                      data-node-type="trigger"
                    >
                      <div class="flex items-center gap-2">
                        <div class="w-3 h-3 bg-success rounded-full"></div>
                        <span class="text-sm font-medium">New Signup</span>
                      </div>
                      <p class="text-xs text-base-content/60 mt-1">When someone joins your list</p>
                    </div>
                    <div
                      class="p-3 bg-success/10 border border-success/20 rounded-lg cursor-pointer hover:bg-success/20 transition-colors"
                      data-node-type="trigger"
                    >
                      <div class="flex items-center gap-2">
                        <div class="w-3 h-3 bg-success rounded-full"></div>
                        <span class="text-sm font-medium">Tag Added</span>
                      </div>
                      <p class="text-xs text-base-content/60 mt-1">When a tag is applied</p>
                    </div>
                  </div>
                </div>

                <div>
                  <h4 class="text-sm font-medium text-base-content/60 mb-2">Actions</h4>
                  <div class="space-y-2">
                    <div
                      class="p-3 bg-primary/10 border border-primary/20 rounded-lg cursor-pointer hover:bg-primary/20 transition-colors"
                      data-node-type="action"
                    >
                      <div class="flex items-center gap-2">
                        <div class="w-3 h-3 bg-primary rounded"></div>
                        <span class="text-sm font-medium">Send Email</span>
                      </div>
                      <p class="text-xs text-base-content/60 mt-1">Send an email to the contact</p>
                    </div>
                    <div
                      class="p-3 bg-primary/10 border border-primary/20 rounded-lg cursor-pointer hover:bg-primary/20 transition-colors"
                      data-node-type="action"
                    >
                      <div class="flex items-center gap-2">
                        <div class="w-3 h-3 bg-primary rounded"></div>
                        <span class="text-sm font-medium">Wait</span>
                      </div>
                      <p class="text-xs text-base-content/60 mt-1">Pause before next action</p>
                    </div>
                  </div>
                </div>

                <div>
                  <h4 class="text-sm font-medium text-base-content/60 mb-2">Decisions</h4>
                  <div class="space-y-2">
                    <div
                      class="p-3 bg-warning/10 border border-warning/20 rounded-lg cursor-pointer hover:bg-warning/20 transition-colors"
                      data-node-type="decision"
                    >
                      <div class="flex items-center gap-2">
                        <div class="w-3 h-3 bg-warning rounded transform rotate-45"></div>
                        <span class="text-sm font-medium">If/Else</span>
                      </div>
                      <p class="text-xs text-base-content/60 mt-1">Split path based on condition</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          <% end %>
          
    <!-- Flow Canvas -->
          <div class="flex-1 relative">
            <div
              id="flow-canvas"
              class="w-full h-full bg-base-200"
              phx-hook="FlowCanvas"
              phx-update="ignore"
            >
              <!-- Canvas will be initialized by the hook -->
              <div class="flex items-center justify-center h-full text-base-content/40">
                <div class="text-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-16 w-16 mx-auto mb-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="1"
                      d="M13 10V3L4 14h7v7l9-11h-7z"
                    />
                  </svg>
                  <p>Loading flow canvas...</p>
                </div>
              </div>
            </div>
            
    <!-- Floating Action Buttons -->
            <div class="absolute bottom-4 right-4 flex flex-col gap-2">
              <button class="btn btn-circle btn-sm btn-ghost bg-base-100 shadow-lg">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-4 w-4"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 4v16m8-8H4"
                  />
                </svg>
              </button>
              <button class="btn btn-circle btn-sm btn-ghost bg-base-100 shadow-lg">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-4 w-4"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 12H6" />
                </svg>
              </button>
            </div>
            
    <!-- Mini-map -->
            <div class="absolute top-4 right-4 w-48 h-32 bg-base-100 border border-base-200 rounded-lg shadow-lg">
              <div class="p-2">
                <h4 class="text-xs font-medium text-base-content/60 mb-2">Overview</h4>
                <div class="w-full h-24 bg-base-200 rounded relative">
                  <!-- Mini-map content will be rendered here -->
                </div>
              </div>
            </div>
          </div>
          
    <!-- Node Properties Panel -->
          <%= if @selected_node do %>
            <div class="w-80 bg-base-100 border-l border-base-200 p-4">
              <h3 class="font-semibold mb-4">Node Properties</h3>
              <div class="alert alert-info">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  class="stroke-current shrink-0 w-6 h-6"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                  >
                  </path>
                </svg>
                <span>Node properties editor coming soon!</span>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp state_badge_class("draft"), do: "badge-ghost"
  defp state_badge_class("active"), do: "badge-success"
  defp state_badge_class("paused"), do: "badge-warning"
  defp state_badge_class("completed"), do: "badge-info"
  defp state_badge_class("archived"), do: "badge-neutral"
  defp state_badge_class(_), do: ""

  defp default_node_data("trigger") do
    %{
      "trigger_type" => "signup",
      "config" => %{}
    }
  end

  defp default_node_data("action") do
    %{
      "action_type" => "send_email",
      "config" => %{}
    }
  end

  defp default_node_data("decision") do
    %{
      "decision_type" => "if_else",
      "config" => %{}
    }
  end

  defp default_node_data(_), do: %{}
end
