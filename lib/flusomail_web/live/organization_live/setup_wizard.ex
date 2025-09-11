defmodule FlusomailWeb.OrganizationLive.SetupWizard do
  use FlusomailWeb, :live_view

  alias Flusomail.{Accounts, Organizations}

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    # Check if user is already part of any organization
    user_orgs = Organizations.list_user_organizations(user)

    # If user already belongs to organizations, redirect to dashboard
    if length(user_orgs) > 0 do
      {:ok, push_navigate(socket, to: ~p"/home")}
    else
      {:ok,
       socket
       |> assign(:step, :welcome)
       |> assign(:organization, %{})
       |> assign(:invitations, [])
       |> assign(:form, to_form(%{}, as: "wizard"))
       |> assign(:skip_available, true)
       |> assign(:domain_check_result, nil)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 py-12 px-4">
      <div class="max-w-3xl mx-auto">
        {render_step(@step, assigns)}
      </div>
    </div>
    """
  end

  defp render_step(:welcome, assigns) do
    ~H"""
    <div class="text-center mb-8">
      <h1 class="text-4xl font-bold mb-4">Welcome to FlusoMail! 🎉</h1>
      <p class="text-lg text-base-content/70 mb-8">
        Let's set up your organization to get the most out of FlusoMail.
      </p>
    </div>

    <div class="card bg-base-200 shadow-xl">
      <div class="card-body">
        <h2 class="card-title text-2xl mb-4">What would you like to do?</h2>

        <div class="space-y-4">
          <div
            class="border rounded-lg p-6 hover:bg-base-300 transition-colors cursor-pointer"
            phx-click="start_setup"
          >
            <h3 class="text-xl font-semibold mb-2">🏢 Set up my organization</h3>
            <p class="text-base-content/70">
              Create your company profile and invite team members to collaborate.
            </p>
          </div>

          <div
            class="border rounded-lg p-6 hover:bg-base-300 transition-colors cursor-pointer"
            phx-click="skip_setup"
          >
            <h3 class="text-xl font-semibold mb-2">👤 Continue solo for now</h3>
            <p class="text-base-content/70">
              Skip organization setup and explore FlusoMail on your own. You can always set this up later.
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_step(:organization_details, assigns) do
    ~H"""
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <h2 class="text-3xl font-bold">Organization Details</h2>
        <div class="text-sm text-base-content/50">Step 1 of 3</div>
      </div>
      <progress class="progress progress-primary w-full mt-4" value="33" max="100"></progress>
    </div>

    <div class="card bg-base-200 shadow-xl">
      <div class="card-body">
        <div class="alert alert-info mb-6">
          <.icon name="hero-information-circle" class="size-6" />
          <div>
            <p class="font-semibold">Domain Security</p>
            <p class="text-sm">
              We'll check if this domain is already claimed by another verified organization to prevent takeovers.
            </p>
          </div>
        </div>

        <.form
          for={@form}
          phx-change="validate_org"
          phx-submit={if @domain_check_result == {:available}, do: "save_org", else: "check_domain"}
          class="space-y-6"
        >
          <.input
            field={@form[:org_domain]}
            type="text"
            label="Company Website Domain"
            placeholder="acme.com"
            required
            phx-mounted={JS.focus()}
          />

          <%= if @domain_check_result do %>
            <%= case @domain_check_result do %>
              <% {:available} -> %>
                <div class="alert alert-success">
                  <.icon name="hero-check-circle" class="size-6" />
                  <div>
                    <p class="font-semibold">Domain Available</p>
                    <p class="text-sm">You can create an organization with this domain.</p>
                  </div>
                </div>

                <.input
                  field={@form[:org_name]}
                  type="text"
                  label="Organization Name"
                  placeholder="Acme Corporation"
                  required
                />

                <.input
                  field={@form[:org_size]}
                  type="select"
                  label="Organization Size"
                  options={[
                    {"1-10 employees", "small"},
                    {"11-50 employees", "medium"},
                    {"51-200 employees", "large"},
                    {"200+ employees", "enterprise"}
                  ]}
                />

                <.input
                  field={@form[:industry]}
                  type="text"
                  label="Industry (Optional)"
                  placeholder="Technology, Healthcare, Finance, etc."
                />
              <% {:exists_unverified, org} -> %>
                <div class="alert alert-warning">
                  <.icon name="hero-exclamation-triangle" class="size-6" />
                  <div>
                    <p class="font-semibold">Organization Exists (Unverified)</p>
                    <p class="text-sm">
                      "{org.name}" already exists with this domain but hasn't verified ownership yet. You can request to join or take ownership.
                    </p>
                  </div>
                </div>

                <div class="flex gap-4 mt-4">
                  <.button
                    type="button"
                    phx-click="request_join"
                    phx-value-org-id={org.id}
                    class="btn btn-primary"
                  >
                    Request to Join
                  </.button>
                  <.button
                    type="button"
                    phx-click="claim_ownership"
                    phx-value-org-id={org.id}
                    class="btn btn-secondary"
                  >
                    Claim Ownership
                  </.button>
                </div>
              <% {:exists_verified, org} -> %>
                <div class="alert alert-error">
                  <.icon name="hero-x-circle" class="size-6" />
                  <div>
                    <p class="font-semibold">Domain Already Taken</p>
                    <p class="text-sm">
                      "{org.name}" already owns and verified this domain. You cannot create a new organization with this domain.
                    </p>
                  </div>
                </div>

                <.button
                  type="button"
                  phx-click="request_invite"
                  phx-value-org-id={org.id}
                  class="btn btn-primary mt-4"
                >
                  Request Invitation
                </.button>
            <% end %>
          <% end %>

          <div class="flex justify-between pt-6">
            <.button type="button" phx-click="back" class="btn btn-ghost">
              ← Back
            </.button>
            <.button type="submit" class="btn btn-primary">
              <%= if @domain_check_result == {:available} do %>
                Continue →
              <% else %>
                Check Domain
              <% end %>
            </.button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  defp render_step(:team_invitations, assigns) do
    ~H"""
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <h2 class="text-3xl font-bold">Invite Your Team</h2>
        <div class="text-sm text-base-content/50">Step 2 of 3</div>
      </div>
      <progress class="progress progress-primary w-full mt-4" value="66" max="100"></progress>
    </div>

    <div class="card bg-base-200 shadow-xl">
      <div class="card-body">
        <p class="mb-6 text-base-content/70">
          Invite team members to help manage your organization. They'll receive an email invitation to join.
        </p>

        <div class="space-y-4 mb-6">
          <%= for {invitation, index} <- Enum.with_index(@invitations) do %>
            <div class="flex gap-4 items-start">
              <div class="flex-1">
                <.input
                  name={"invitation[#{index}][email]"}
                  type="email"
                  label={if index == 0, do: "Email Address", else: nil}
                  placeholder="colleague@acme.com"
                  value={invitation[:email]}
                  phx-blur="update_invitation"
                  phx-value-index={index}
                />
              </div>
              <div class="w-40">
                <.input
                  name={"invitation[#{index}][role]"}
                  type="select"
                  label={if index == 0, do: "Role", else: nil}
                  options={[
                    {"Admin", "admin"},
                    {"Member", "member"}
                  ]}
                  value={invitation[:role] || "member"}
                  phx-change="update_invitation_role"
                  phx-value-index={index}
                />
              </div>
              <button
                type="button"
                class="btn btn-ghost btn-sm mt-8"
                phx-click="remove_invitation"
                phx-value-index={index}
              >
                <.icon name="hero-trash" class="size-5" />
              </button>
            </div>
          <% end %>
        </div>

        <button type="button" class="btn btn-outline btn-sm" phx-click="add_invitation">
          <.icon name="hero-plus" class="size-4" /> Add another team member
        </button>

        <div class="flex justify-between pt-6 mt-6 border-t">
          <.button type="button" phx-click="back" class="btn btn-ghost">
            ← Back
          </.button>
          <div class="space-x-2">
            <.button type="button" phx-click="skip_invitations" class="btn btn-ghost">
              Skip for now
            </.button>
            <.button type="button" phx-click="save_invitations" class="btn btn-primary">
              Continue →
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_step(:confirmation, assigns) do
    ~H"""
    <div class="mb-8">
      <div class="flex items-center justify-between">
        <h2 class="text-3xl font-bold">Review & Confirm</h2>
        <div class="text-sm text-base-content/50">Step 3 of 3</div>
      </div>
      <progress class="progress progress-primary w-full mt-4" value="100" max="100"></progress>
    </div>

    <div class="card bg-base-200 shadow-xl">
      <div class="card-body">
        <h3 class="text-xl font-semibold mb-4">Organization Summary</h3>

        <div class="bg-base-100 rounded-lg p-4 mb-6">
          <dl class="space-y-2">
            <div class="flex justify-between">
              <dt class="font-medium">Organization Name:</dt>
              <dd>{@organization[:org_name]}</dd>
            </div>
            <div class="flex justify-between">
              <dt class="font-medium">Domain:</dt>
              <dd>{@organization[:org_domain]}</dd>
            </div>
            <%= if @organization[:org_size] do %>
              <div class="flex justify-between">
                <dt class="font-medium">Size:</dt>
                <dd>{format_org_size(@organization[:org_size])}</dd>
              </div>
            <% end %>
            <%= if @organization[:industry] do %>
              <div class="flex justify-between">
                <dt class="font-medium">Industry:</dt>
                <dd>{@organization[:industry]}</dd>
              </div>
            <% end %>
          </dl>
        </div>

        <%= if length(@invitations) > 0 do %>
          <h3 class="text-xl font-semibold mb-4">Team Invitations</h3>
          <div class="bg-base-100 rounded-lg p-4 mb-6">
            <ul class="space-y-2">
              <%= for invitation <- @invitations do %>
                <li class="flex justify-between">
                  <span>{invitation[:email]}</span>
                  <span class="badge badge-primary">{invitation[:role]}</span>
                </li>
              <% end %>
            </ul>
          </div>
        <% end %>

        <div class="alert alert-info mb-6">
          <.icon name="hero-information-circle" class="size-6" />
          <div>
            <p class="font-semibold">What happens next?</p>
            <p class="text-sm">
              We'll create your organization and send invitations to your team members.
              You'll need to verify your domain ownership to start sending emails.
            </p>
          </div>
        </div>

        <div class="flex justify-between">
          <.button type="button" phx-click="back" class="btn btn-ghost">
            ← Back
          </.button>
          <.button type="button" phx-click="complete_setup" class="btn btn-primary">
            Complete Setup
          </.button>
        </div>
      </div>
    </div>
    """
  end

  defp render_step(:success, assigns) do
    ~H"""
    <div class="text-center">
      <div class="mb-8">
        <span class="text-6xl">🎊</span>
      </div>
      <h2 class="text-3xl font-bold mb-4">All Set!</h2>
      <p class="text-lg text-base-content/70 mb-8">
        Your organization has been created and invitations have been sent to your team.
      </p>

      <div class="card bg-base-200 shadow-xl max-w-md mx-auto">
        <div class="card-body">
          <h3 class="text-xl font-semibold mb-4">Next Steps</h3>
          <ul class="text-left space-y-3">
            <li class="flex items-start gap-2">
              <.icon name="hero-check-circle" class="size-5 text-success mt-0.5" />
              <span>Verify your domain ownership to enable email sending</span>
            </li>
            <li class="flex items-start gap-2">
              <.icon name="hero-check-circle" class="size-5 text-success mt-0.5" />
              <span>Configure your email templates</span>
            </li>
            <li class="flex items-start gap-2">
              <.icon name="hero-check-circle" class="size-5 text-success mt-0.5" />
              <span>Set up your first campaign</span>
            </li>
          </ul>

          <div class="card-actions justify-center mt-6">
            <.link navigate={~p"/organizations/#{@organization[:id]}"} class="btn btn-primary">
              Go to Organization Dashboard
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("start_setup", _params, socket) do
    {:noreply, assign(socket, :step, :organization_details)}
  end

  def handle_event("skip_setup", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/home")}
  end

  def handle_event("back", _params, socket) do
    {new_step, updated_socket} =
      case socket.assigns.step do
        :organization_details ->
          {:welcome, socket}

        :team_invitations ->
          {:organization_details, socket}

        :confirmation ->
          # When going back to team invitations, ensure there's at least one empty slot
          invitations =
            if length(socket.assigns.invitations) == 0 do
              [%{email: "", role: "member"}]
            else
              socket.assigns.invitations ++ [%{email: "", role: "member"}]
            end

          {:team_invitations, assign(socket, :invitations, invitations)}

        _ ->
          {socket.assigns.step, socket}
      end

    {:noreply, assign(updated_socket, :step, new_step)}
  end

  def handle_event("validate_org", %{"wizard" => params}, socket) do
    changeset =
      {%{}, %{org_name: :string, org_domain: :string, org_size: :string, industry: :string}}
      |> Ecto.Changeset.cast(params, [:org_name, :org_domain, :org_size, :industry])
      |> Ecto.Changeset.validate_format(
        :org_domain,
        ~r/^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$/,
        message: "must be a valid domain"
      )

    {:noreply,
     assign(socket, form: to_form(Map.put(changeset, :action, :validate), as: "wizard"))}
  end

  def handle_event("check_domain", %{"wizard" => params}, socket) do
    domain = String.trim(params["org_domain"] || "")

    if domain != "" do
      result = Organizations.check_domain_availability(domain)
      {:noreply, assign(socket, :domain_check_result, result)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("request_join", %{"org-id" => _org_id}, socket) do
    # TODO: Implement join request functionality
    {:noreply,
     socket
     |> put_flash(:info, "Join request sent! You'll be notified when an admin approves.")
     |> push_navigate(to: ~p"/home")}
  end

  def handle_event("claim_ownership", %{"org-id" => _org_id}, socket) do
    # TODO: Implement ownership claim functionality  
    {:noreply,
     socket
     |> put_flash(:info, "Ownership claim submitted! Check your email for verification steps.")
     |> push_navigate(to: ~p"/home")}
  end

  def handle_event("request_invite", %{"org-id" => _org_id}, socket) do
    # TODO: Implement invitation request functionality
    {:noreply,
     socket
     |> put_flash(:info, "Invitation request sent! You'll be notified if approved.")
     |> push_navigate(to: ~p"/home")}
  end

  def handle_event("save_org", %{"wizard" => params}, socket) do
    # Convert string keys to atom keys for template compatibility
    organization = %{
      org_name: params["org_name"],
      org_domain: params["org_domain"],
      org_size: params["org_size"],
      industry: params["industry"]
    }

    {:noreply,
     socket
     |> assign(:organization, organization)
     |> assign(:invitations, [%{email: "", role: "member"}])
     |> assign(:step, :team_invitations)}
  end

  def handle_event("add_invitation", _params, socket) do
    invitations = socket.assigns.invitations ++ [%{email: "", role: "member"}]
    {:noreply, assign(socket, :invitations, invitations)}
  end

  def handle_event("remove_invitation", %{"index" => index}, socket) do
    index = String.to_integer(index)
    invitations = List.delete_at(socket.assigns.invitations, index)
    {:noreply, assign(socket, :invitations, invitations)}
  end

  def handle_event("update_invitation", %{"value" => email, "index" => index}, socket) do
    index = String.to_integer(index)
    invitations = List.update_at(socket.assigns.invitations, index, &Map.put(&1, :email, email))
    {:noreply, assign(socket, :invitations, invitations)}
  end

  def handle_event("update_invitation_role", params, socket) do
    index = String.to_integer(params["index"])
    role = params["invitation"][to_string(index)]["role"]
    invitations = List.update_at(socket.assigns.invitations, index, &Map.put(&1, :role, role))
    {:noreply, assign(socket, :invitations, invitations)}
  end

  def handle_event("skip_invitations", _params, socket) do
    {:noreply,
     socket
     |> assign(:invitations, [])
     |> assign(:step, :confirmation)}
  end

  def handle_event("save_invitations", _params, socket) do
    # Filter out empty email invitations
    valid_invitations = Enum.filter(socket.assigns.invitations, &(&1[:email] && &1[:email] != ""))

    {:noreply,
     socket
     |> assign(:invitations, valid_invitations)
     |> assign(:step, :confirmation)}
  end

  def handle_event("complete_setup", _params, socket) do
    user = socket.assigns.current_scope.user
    org_params = socket.assigns.organization

    case create_organization_with_invitations(user, org_params, socket.assigns.invitations) do
      {:ok, organization} ->
        {:noreply,
         socket
         |> assign(:organization, Map.put(socket.assigns.organization, :id, organization.id))
         |> assign(:step, :success)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to create organization. Please try again.")
         |> assign(:step, :organization_details)}
    end
  end

  defp create_organization_with_invitations(user, org_params, invitations) do
    Flusomail.Repo.transaction(fn ->
      # Create organization
      org_attrs = %{
        name: org_params[:org_name] || org_params["org_name"],
        slug:
          (org_params[:org_name] || org_params["org_name"])
          |> String.downcase()
          |> String.replace(~r/[^a-z0-9]/, "-"),
        billing_email: user.email,
        plan: "trial",
        status: "active",
        settings: %{
          size: org_params[:org_size] || org_params["org_size"],
          industry: org_params[:industry] || org_params["industry"]
        }
      }

      scope = %Accounts.Scope{user: user}

      case Organizations.create_organization(scope, org_attrs) do
        {:ok, organization} ->
          # Create organization_user relationship
          Organizations.OrganizationUser.changeset(%Organizations.OrganizationUser{}, %{
            organization_id: organization.id,
            user_id: user.id,
            role: "owner",
            status: "active",
            joined_at: DateTime.utc_now()
          })
          |> Flusomail.Repo.insert!()

          # Create domain
          %Organizations.Domain{}
          |> Organizations.Domain.changeset(
            %{
              name: org_params[:org_domain] || org_params["org_domain"],
              status: "pending"
            },
            organization
          )
          |> Flusomail.Repo.insert!()

          # Send invitations
          Enum.each(invitations, fn invitation ->
            # TODO: Create invitation records and send emails
            # For now, we'll just log them
            IO.inspect(invitation, label: "Would send invitation to")
          end)

          organization

        {:error, changeset} ->
          Flusomail.Repo.rollback(changeset)
      end
    end)
  end

  defp format_org_size("small"), do: "1-10 employees"
  defp format_org_size("medium"), do: "11-50 employees"
  defp format_org_size("large"), do: "51-200 employees"
  defp format_org_size("enterprise"), do: "200+ employees"
  defp format_org_size(_), do: "Not specified"
end
