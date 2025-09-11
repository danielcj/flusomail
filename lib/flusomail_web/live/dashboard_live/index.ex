defmodule FlusomailWeb.DashboardLive.Index do
  use FlusomailWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold mb-6">Welcome to FlusoMail</h1>
      <p class="text-lg mb-8">You're now logged in to your dashboard.</p>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="card bg-base-200 shadow-lg">
          <div class="card-body">
            <h2 class="card-title">Organizations</h2>
            <p>Manage your organizations and team access.</p>
            <div class="card-actions justify-end">
              <.link navigate={~p"/organizations"} class="btn btn-primary">
                View Organizations
              </.link>
            </div>
          </div>
        </div>

        <div class="card bg-base-200 shadow-lg">
          <div class="card-body">
            <h2 class="card-title">Domains</h2>
            <p>Set up and verify sending domains.</p>
            <div class="card-actions justify-end">
              <button class="btn btn-secondary" disabled>
                Coming Soon
              </button>
            </div>
          </div>
        </div>

        <div class="card bg-base-200 shadow-lg">
          <div class="card-body">
            <h2 class="card-title">Campaigns</h2>
            <p>Create and manage email campaigns.</p>
            <div class="card-actions justify-end">
              <button class="btn btn-secondary" disabled>
                Coming Soon
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
