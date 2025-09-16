defmodule FlusomailWeb.FlowLive.Index do
  use FlusomailWeb, :live_view

  alias Flusomail.Flows
  alias Flusomail.Flows.Flow

  @impl true
  def mount(_params, _session, socket) do
    flows = Flows.list_flows(socket.assigns.current_scope.organization_id)

    {:ok,
     socket
     |> assign(:page_title, "Flows")
     |> assign(:flows, flows)
     |> assign(:flow, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Flow")
    |> assign(:flow, Flows.get_flow!(socket.assigns.current_scope.organization_id, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Flow")
    |> assign(:flow, %Flow{
      organization_id: socket.assigns.current_scope.organization_id,
      created_by_id: socket.assigns.current_user.id
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Flows")
    |> assign(:flow, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    flow = Flows.get_flow!(socket.assigns.current_scope.organization_id, id)
    {:ok, _} = Flows.delete_flow(flow)

    {:noreply,
     socket
     |> put_flash(:info, "Flow deleted successfully")
     |> assign(:flows, Flows.list_flows(socket.assigns.current_scope.organization_id))}
  end

  def handle_event("duplicate", %{"id" => id}, socket) do
    flow = Flows.get_flow!(socket.assigns.current_scope.organization_id, id)

    case Flows.duplicate_flow(flow, "#{flow.name} (Copy)") do
      {:ok, _new_flow} ->
        {:noreply,
         socket
         |> put_flash(:info, "Flow duplicated successfully")
         |> assign(:flows, Flows.list_flows(socket.assigns.current_scope.organization_id))}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to duplicate flow")}
    end
  end

  def handle_event("toggle_state", %{"id" => id}, socket) do
    flow = Flows.get_flow!(socket.assigns.current_scope.organization_id, id)

    result =
      case flow.state do
        "draft" -> Flows.activate_flow(flow)
        "active" -> Flows.pause_flow(flow)
        "paused" -> Flows.activate_flow(flow)
        _ -> {:error, :invalid_state}
      end

    case result do
      {:ok, _updated_flow} ->
        {:noreply,
         socket
         |> put_flash(:info, "Flow state updated successfully")
         |> assign(:flows, Flows.list_flows(socket.assigns.current_scope.organization_id))}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to update flow state")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-8">
        <div class="flex justify-between items-center mb-6">
          <div>
            <h1 class="text-3xl font-bold">Flows</h1>
            <p class="text-base-content/60 mt-1">
              Visual campaigns and automations that actually make sense
            </p>
          </div>
          <.link
            navigate={~p"/flows/new"}
            class="btn btn-primary"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 mr-2"
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
            Create Flow
          </.link>
        </div>

        <%= if @flows == [] do %>
          <div class="text-center py-12">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-24 w-24 mx-auto text-base-content/20 mb-4"
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
            <h3 class="text-lg font-semibold mb-2">No flows yet</h3>
            <p class="text-base-content/60 mb-4">
              Create your first flow to start engaging with your audience
            </p>
            <.link
              navigate={~p"/flows/new"}
              class="btn btn-primary"
            >
              Create Your First Flow
            </.link>
          </div>
        <% else %>
          <div class="grid gap-4 grid-cols-1 lg:grid-cols-2 xl:grid-cols-3">
            <%= for flow <- @flows do %>
              <div class="card bg-base-100 shadow-xl hover:shadow-2xl transition-shadow">
                <div class="card-body">
                  <div class="flex justify-between items-start">
                    <h2 class="card-title">
                      {flow.name}
                    </h2>
                    <div class={"badge #{state_badge_class(flow.state)}"}>
                      {flow.state}
                    </div>
                  </div>

                  <p class="text-base-content/60 text-sm">
                    {flow.description || "No description"}
                  </p>

                  <div class="flex items-center gap-4 text-sm text-base-content/60 mt-2">
                    <span class="flex items-center gap-1">
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
                          d="M7 20l4-16m2 16l4-16M6 9h14M4 15h14"
                        />
                      </svg>
                      {flow.flow_type}
                    </span>
                    <span class="flex items-center gap-1">
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
                          d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                        />
                      </svg>
                      {format_date(flow.updated_at)}
                    </span>
                  </div>

                  <div class="stats shadow mt-4">
                    <div class="stat py-2 px-4">
                      <div class="stat-title text-xs">Entered</div>
                      <div class="stat-value text-lg">{flow.stats["total_entered"] || 0}</div>
                    </div>
                    <div class="stat py-2 px-4">
                      <div class="stat-title text-xs">Active</div>
                      <div class="stat-value text-lg">{flow.stats["currently_active"] || 0}</div>
                    </div>
                    <div class="stat py-2 px-4">
                      <div class="stat-title text-xs">Completed</div>
                      <div class="stat-value text-lg">{flow.stats["completed"] || 0}</div>
                    </div>
                  </div>

                  <div class="card-actions justify-end mt-4">
                    <.link
                      navigate={~p"/flows/#{flow}/edit"}
                      class="btn btn-sm btn-ghost"
                    >
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
                          d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                        />
                      </svg>
                      Edit
                    </.link>

                    <%= if flow.state in ["draft", "paused"] do %>
                      <button
                        phx-click="toggle_state"
                        phx-value-id={flow.id}
                        class="btn btn-sm btn-success"
                      >
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
                      <%= if flow.state == "active" do %>
                        <button
                          phx-click="toggle_state"
                          phx-value-id={flow.id}
                          class="btn btn-sm btn-warning"
                        >
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
                              d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z"
                            />
                          </svg>
                          Pause
                        </button>
                      <% end %>
                    <% end %>

                    <div class="dropdown dropdown-end">
                      <label tabindex="0" class="btn btn-sm btn-ghost">
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
                            d="M5 12h.01M12 12h.01M19 12h.01M6 12a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0zm7 0a1 1 0 11-2 0 1 1 0 012 0z"
                          />
                        </svg>
                      </label>
                      <ul
                        tabindex="0"
                        class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52"
                      >
                        <li>
                          <button phx-click="duplicate" phx-value-id={flow.id}>
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
                                d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
                              />
                            </svg>
                            Duplicate
                          </button>
                        </li>
                        <li>
                          <button
                            phx-click="delete"
                            phx-value-id={flow.id}
                            data-confirm="Are you sure you want to delete this flow?"
                            class="text-error"
                          >
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
                                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                              />
                            </svg>
                            Delete
                          </button>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
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

  defp format_date(nil), do: "Never"

  defp format_date(date) do
    Calendar.strftime(date, "%b %d, %Y")
  end
end
