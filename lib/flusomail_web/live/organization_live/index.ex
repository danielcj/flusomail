defmodule FlusomailWeb.OrganizationLive.Index do
  use FlusomailWeb, :live_view

  alias Flusomail.Organizations

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Organizations
        <:actions>
          <.button variant="primary" navigate={~p"/organizations/new"}>
            <.icon name="hero-plus" /> New Organization
          </.button>
        </:actions>
      </.header>

      <.table
        id="organizations"
        rows={@streams.organizations}
        row_click={fn {_id, organization} -> JS.navigate(~p"/organizations/#{organization}") end}
      >
        <:col :let={{_id, organization}} label="Name">{organization.name}</:col>
        <:col :let={{_id, organization}} label="Slug">{organization.slug}</:col>
        <:col :let={{_id, organization}} label="Settings">{inspect(organization.settings)}</:col>
        <:col :let={{_id, organization}} label="Billing email">{organization.billing_email}</:col>
        <:col :let={{_id, organization}} label="Plan">{organization.plan}</:col>
        <:col :let={{_id, organization}} label="Status">{organization.status}</:col>
        <:action :let={{_id, organization}}>
          <div class="sr-only">
            <.link navigate={~p"/organizations/#{organization}"}>Show</.link>
          </div>
          <.link navigate={~p"/organizations/#{organization}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, organization}}>
          <.link
            phx-click={JS.push("delete", value: %{id: organization.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Organizations.subscribe_organizations(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Organizations")
     |> stream(:organizations, list_organizations(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    organization = Organizations.get_organization!(socket.assigns.current_scope, id)
    {:ok, _} = Organizations.delete_organization(socket.assigns.current_scope, organization)

    {:noreply, stream_delete(socket, :organizations, organization)}
  end

  @impl true
  def handle_info({type, %Flusomail.Organizations.Organization{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :organizations, list_organizations(socket.assigns.current_scope), reset: true)}
  end

  defp list_organizations(current_scope) do
    Organizations.list_organizations(current_scope)
  end
end
