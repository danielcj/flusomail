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
      <p class="text-lg">You're now logged in to your dashboard.</p>
    </div>
    """
  end
end
