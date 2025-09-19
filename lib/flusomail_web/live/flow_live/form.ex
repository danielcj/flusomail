defmodule FlusomailWeb.FlowLive.Form do
  use FlusomailWeb, :live_view

  alias Flusomail.Flows
  alias Flusomail.Flows.Flow

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
    flow = Flows.get_flow!(get_organization_id(socket.assigns.current_scope), id)

    socket
    |> assign(:page_title, "Edit Flow")
    |> assign(:flow, flow)
    |> assign(:form, to_form(Flows.change_flow(flow)))
  end

  defp apply_action(socket, :new, _params) do
    flow = %Flow{
      organization_id: get_organization_id(socket.assigns.current_scope),
      created_by_id: get_user_id(socket.assigns.current_scope)
    }

    socket
    |> assign(:page_title, "New Flow")
    |> assign(:flow, flow)
    |> assign(:form, to_form(Flows.change_flow(flow)))
  end

  @impl true
  def handle_event("validate", %{"flow" => flow_params}, socket) do
    changeset = Flows.change_flow(socket.assigns.flow, flow_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"flow" => flow_params}, socket) do
    save_flow(socket, socket.assigns.live_action, flow_params)
  end

  defp save_flow(socket, :edit, flow_params) do
    case Flows.update_flow(socket.assigns.flow, flow_params) do
      {:ok, flow} ->
        {:noreply,
         socket
         |> put_flash(:info, "Flow updated successfully")
         |> push_navigate(to: ~p"/flows/#{flow}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_flow(socket, :new, flow_params) do
    flow_params =
      flow_params
      |> Map.put("organization_id", get_organization_id(socket.assigns.current_scope))
      |> Map.put("created_by_id", get_user_id(socket.assigns.current_scope))

    case Flows.create_flow(flow_params) do
      {:ok, flow} ->
        {:noreply,
         socket
         |> put_flash(:info, "Flow created successfully")
         |> push_navigate(to: ~p"/flows/#{flow}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-8 max-w-2xl mx-auto">
        <div class="mb-6">
          <.link navigate={~p"/flows"} class="btn btn-ghost btn-sm mb-4">
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
            Back to Flows
          </.link>
          <h1 class="text-3xl font-bold">
            {if @live_action == :new, do: "Create New Flow", else: "Edit Flow"}
          </h1>
        </div>

        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <.form
              for={@form}
              id="flow-form"
              phx-change="validate"
              phx-submit="save"
              class="space-y-6"
            >
              <.input
                field={@form[:name]}
                type="text"
                label="Flow Name"
                placeholder="e.g. Welcome Series, Abandoned Cart Recovery"
                required
              />

              <.input
                field={@form[:description]}
                type="textarea"
                label="Description"
                placeholder="Describe what this flow does and when it triggers"
                rows="3"
              />

              <.input
                field={@form[:flow_type]}
                type="select"
                label="Flow Type"
                prompt="Choose flow type"
                options={[
                  {"Automation - Triggered by events", "automation"},
                  {"Campaign - Scheduled broadcast", "campaign"},
                  {"Transactional - API triggered", "transactional"}
                ]}
                required
              />

              <%= if @live_action == :new do %>
                <div class="form-control">
                  <label class="label">
                    <span class="label-text">Template</span>
                  </label>
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="card bg-base-200 cursor-pointer hover:bg-base-300 transition-colors">
                      <div class="card-body py-4">
                        <h3 class="font-semibold">Start from Scratch</h3>
                        <p class="text-sm text-base-content/60">Build your flow from the ground up</p>
                      </div>
                    </div>
                    <div class="card bg-base-200 cursor-pointer hover:bg-base-300 transition-colors opacity-50">
                      <div class="card-body py-4">
                        <h3 class="font-semibold">Welcome Series</h3>
                        <p class="text-sm text-base-content/60">3-email nurture sequence</p>
                        <div class="badge badge-sm">Coming Soon</div>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>

              <div class="flex gap-4 pt-4">
                <.button phx-disable-with="Saving..." class="btn btn-primary">
                  {if @live_action == :new, do: "Create Flow", else: "Update Flow"}
                </.button>
                <.link navigate={~p"/flows"} class="btn btn-ghost">
                  Cancel
                </.link>
              </div>
            </.form>
          </div>
        </div>

        <%= if @live_action == :new do %>
          <div class="alert alert-info mt-6">
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
            <span>
              After creating your flow, you'll be taken to the visual canvas where you can drag and drop nodes to build your automation.
            </span>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
