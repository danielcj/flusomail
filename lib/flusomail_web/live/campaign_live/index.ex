defmodule FlusomailWeb.CampaignLive.Index do
  use FlusomailWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-8">
        <div class="flex justify-between items-center mb-6">
          <h1 class="text-3xl font-bold">Campaigns</h1>
          <button class="btn btn-primary">
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
            New Campaign
          </button>
        </div>
        <div class="alert alert-info">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            class="stroke-info shrink-0 w-6 h-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            >
            </path>
          </svg>
          <div>
            <span class="font-medium">Campaigns are now visual Flows!</span>
            <p class="text-sm mt-1">Create beautiful email campaigns with drag-and-drop flows.</p>
            <.link navigate={~p"/flows"} class="btn btn-sm btn-primary mt-2">
              Go to Flows
            </.link>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
