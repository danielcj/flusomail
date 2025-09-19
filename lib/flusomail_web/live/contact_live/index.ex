defmodule FlusomailWeb.ContactLive.Index do
  use FlusomailWeb, :live_view

  alias Flusomail.Contacts
  alias Flusomail.Contacts.Contact

  defp get_organization_id(scope) do
    case scope.organization do
      %{id: id} -> id
      nil -> nil
    end
  end

  defp get_user_id(scope) do
    scope.user.id
  end

  @impl true
  def mount(_params, _session, socket) do
    organization_id = get_organization_id(socket.assigns.current_scope)
    contacts = Contacts.list_contacts(organization_id)

    {:ok,
     socket
     |> assign(:page_title, "Contacts")
     |> assign(:contacts, contacts)
     |> assign(:contact, nil)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Contact")
    |> assign(
      :contact,
      Contacts.get_contact!(get_organization_id(socket.assigns.current_scope), id)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Contact")
    |> assign(:contact, %Contact{
      organization_id: get_organization_id(socket.assigns.current_scope),
      created_by_id: get_user_id(socket.assigns.current_scope)
    })
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Contacts")
    |> assign(:contact, nil)
  end

  @impl true
  def handle_info({FlusomailWeb.ContactLive.FormComponent, {:saved, contact}}, socket) do
    {:noreply, stream_insert(socket, :contacts, contact)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact = Contacts.get_contact!(get_organization_id(socket.assigns.current_scope), id)
    {:ok, _} = Contacts.delete_contact(contact)

    {:noreply,
     socket
     |> put_flash(:info, "Contact deleted successfully")
     |> assign(
       :contacts,
       Contacts.list_contacts(get_organization_id(socket.assigns.current_scope))
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-8">
        <div class="flex justify-between items-center mb-6">
          <h1 class="text-3xl font-bold">Contacts</h1>
          <.link navigate={~p"/contacts/new"} class="btn btn-primary">
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
            Add Contact
          </.link>
        </div>

        <%= if Enum.empty?(@contacts) do %>
          <div class="text-center py-12">
            <div class="mx-auto h-12 w-12 text-base-content/40">
              <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 515.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 919.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
            </div>
            <h3 class="mt-2 text-sm font-medium text-base-content">No contacts</h3>
            <p class="mt-1 text-sm text-base-content/60">Get started by adding your first contact.</p>
            <div class="mt-6">
              <.link navigate={~p"/contacts/new"} class="btn btn-primary">
                Add Contact
              </.link>
            </div>
          </div>
        <% else %>
          <div class="overflow-x-auto">
            <table class="table table-zebra">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Added</th>
                  <th class="w-32">Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={contact <- @contacts} id={"contact-#{contact.id}"}>
                  <td class="font-medium">
                    <%= if contact.name && String.trim(contact.name) != "" do %>
                      {contact.name}
                    <% else %>
                      <span class="text-base-content/40 italic">{contact.email}</span>
                    <% end %>
                  </td>
                  <td>{contact.email}</td>
                  <td class="text-sm text-base-content/60">
                    {Calendar.strftime(contact.inserted_at, "%b %d, %Y")}
                  </td>
                  <td>
                    <div class="flex gap-2">
                      <.link
                        navigate={~p"/contacts/#{contact}/edit"}
                        class="btn btn-ghost btn-sm"
                        title="Edit contact"
                      >
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                          />
                        </svg>
                      </.link>
                      <button
                        phx-click="delete"
                        phx-value-id={contact.id}
                        data-confirm="Are you sure you want to delete this contact?"
                        class="btn btn-ghost btn-sm text-error"
                        title="Delete contact"
                      >
                        <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                          />
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
