defmodule FlusomailWeb.DashboardLive.Index do
  use FlusomailWeb, :live_view

  alias Flusomail.Contacts

  defp get_organization_id(scope) do
    case scope.organization do
      %{id: id} -> id
      nil -> nil
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    organization_id = get_organization_id(socket.assigns.current_scope)
    contact_count = Contacts.count_contacts(organization_id)

    {:ok, assign(socket, :contact_count, contact_count)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.dashboard />
    </Layouts.app>
    """
  end

  defp dashboard(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold mb-6">Dashboard</h1>
      <p class="text-lg mb-8">Welcome back to FlusoMail!</p>

      <div class="stats shadow w-full mb-8">
        <div class="stat">
          <div class="stat-figure text-primary">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              class="inline-block w-8 h-8 stroke-current"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
              >
              </path>
            </svg>
          </div>
          <div class="stat-title">Total Sent</div>
          <div class="stat-value">0</div>
          <div class="stat-desc">This month</div>
        </div>

        <div class="stat">
          <div class="stat-figure text-secondary">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              class="inline-block w-8 h-8 stroke-current"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              >
              </path>
            </svg>
          </div>
          <div class="stat-title">Open Rate</div>
          <div class="stat-value">--%</div>
          <div class="stat-desc">30 day average</div>
        </div>

        <div class="stat">
          <div class="stat-figure text-accent">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              class="inline-block w-8 h-8 stroke-current"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 515.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 919.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
              />
            </svg>
          </div>
          <div class="stat-title">Contacts</div>
          <div class="stat-value"><%= @contact_count %></div>
          <div class="stat-desc">
            <%= if @contact_count == 0 do %>
              <.link navigate={~p"/contacts/new"} class="link link-accent">Add your first contact</.link>
            <% else %>
              Total contacts
            <% end %>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <h2 class="card-title">Quick Actions</h2>
            <div class="space-y-2">
              <.link navigate={~p"/flows"} class="btn btn-primary btn-block">
                Create Flow
              </.link>
              <%= if @contact_count == 0 do %>
                <.link navigate={~p"/contacts/new"} class="btn btn-secondary btn-block">
                  Add First Contact
                </.link>
              <% else %>
                <.link navigate={~p"/contacts"} class="btn btn-secondary btn-block">
                  Manage Contacts (<%= @contact_count %>)
                </.link>
              <% end %>
              <.link navigate={~p"/analytics"} class="btn btn-accent btn-block">
                View Analytics
              </.link>
            </div>
          </div>
        </div>

        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <h2 class="card-title">Recent Activity</h2>
            <p class="text-base-content/60">No recent activity to display.</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
