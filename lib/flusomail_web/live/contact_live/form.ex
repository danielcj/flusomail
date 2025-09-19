defmodule FlusomailWeb.ContactLive.Form do
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
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    contact = Contacts.get_contact!(get_organization_id(socket.assigns.current_scope), id)

    socket
    |> assign(:page_title, "Edit Contact")
    |> assign(:contact, contact)
    |> assign(:form, to_form(Contacts.change_contact(contact)))
  end

  defp apply_action(socket, :new, _params) do
    contact = %Contact{
      organization_id: get_organization_id(socket.assigns.current_scope),
      created_by_id: get_user_id(socket.assigns.current_scope)
    }

    socket
    |> assign(:page_title, "New Contact")
    |> assign(:contact, contact)
    |> assign(:form, to_form(Contacts.change_contact(contact)))
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset = Contacts.change_contact(socket.assigns.contact, contact_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact" => contact_params}, socket) do
    save_contact(socket, socket.assigns.live_action, contact_params)
  end

  defp save_contact(socket, :edit, contact_params) do
    case Contacts.update_contact(socket.assigns.contact, contact_params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Contact updated successfully")
         |> push_navigate(to: ~p"/contacts")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_contact(socket, :new, contact_params) do
    contact_params =
      contact_params
      |> Map.put("organization_id", get_organization_id(socket.assigns.current_scope))
      |> Map.put("created_by_id", get_user_id(socket.assigns.current_scope))

    case Contacts.create_contact(contact_params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Contact created successfully")
         |> push_navigate(to: ~p"/contacts")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-8">
        <div class="flex items-center gap-4 mb-6">
          <.link navigate={~p"/contacts"} class="btn btn-ghost btn-sm">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 19l-7-7 7-7"
              />
            </svg>
            Back to Contacts
          </.link>
          <h1 class="text-3xl font-bold">{@page_title}</h1>
        </div>

        <div class="max-w-2xl">
          <.form
            for={@form}
            id="contact-form"
            phx-change="validate"
            phx-submit="save"
            class="space-y-6"
          >
            <div class="form-control">
              <label class="label">
                <span class="label-text font-medium">Email</span>
              </label>
              <.input
                field={@form[:email]}
                type="email"
                placeholder="Enter email address"
                class="input input-bordered w-full"
                required
              />
            </div>

            <div class="form-control">
              <label class="label">
                <span class="label-text font-medium">
                  Name <span class="text-base-content/50">(optional)</span>
                </span>
              </label>
              <.input
                field={@form[:name]}
                type="text"
                placeholder="Enter contact name (optional)"
                class="input input-bordered w-full"
              />
            </div>

            <div class="flex gap-4 pt-4">
              <button type="submit" phx-disable-with="Saving..." class="btn btn-primary">
                Save Contact
              </button>
              <.link navigate={~p"/contacts"} class="btn btn-ghost">
                Cancel
              </.link>
            </div>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
