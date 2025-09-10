defmodule FlusomailWeb.UserLive.Registration do
  use FlusomailWeb, :live_view

  alias Flusomail.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.auth flash={@flash}>
      <div class="text-center mb-8">
        <h2 class="text-3xl font-bold">Create Your Organization</h2>
        <p class="mt-2 text-sm text-base-content/70">
          Already have an account?
          <.link navigate={~p"/users/log-in"} class="font-semibold text-primary hover:underline">
            Log in
          </.link>
        </p>
      </div>

      <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate" class="space-y-6">
        <div class="space-y-4">
          <div>
            <h3 class="text-lg font-medium mb-4">Organization Details</h3>
            <.input
              field={@form[:org_name]}
              type="text"
              label="Organization Name"
              placeholder="Your Company Inc."
              required
              phx-mounted={JS.focus()}
            />
            <.input
              field={@form[:org_domain]}
              type="text"
              label="Domain"
              placeholder="yourcompany.com"
              required
            />
          </div>
          
          <div>
            <h3 class="text-lg font-medium mb-4">Admin User</h3>
            <.input
              field={@form[:name]}
              type="text"
              label="Your Name"
              placeholder="John Doe"
              required
            />
            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              placeholder="john@yourcompany.com"
              autocomplete="username"
              required
            />
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              autocomplete="new-password"
              required
            />
          </div>
        </div>

        <.button phx-disable-with="Creating organization..." class="btn btn-primary w-full">
          Create Organization & Account
        </.button>
      </.form>
    </Layouts.auth>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: FlusomailWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Ecto.Changeset.cast({%{}, %{org_name: :string, org_domain: :string, name: :string, email: :string, password: :string}}, %{}, [:org_name, :org_domain, :name, :email, :password])

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    case Accounts.register_organization_and_admin_user(params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "Organization created! An email was sent to #{user.email} to confirm your account."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
      
      {:error, :domain_taken} ->
        changeset = 
          Ecto.Changeset.cast({%{}, %{org_name: :string, org_domain: :string, name: :string, email: :string, password: :string}}, params, [:org_name, :org_domain, :name, :email, :password])
          |> Ecto.Changeset.add_error(:org_domain, "is already taken by a verified organization")
        
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset = 
      Ecto.Changeset.cast({%{}, %{org_name: :string, org_domain: :string, name: :string, email: :string, password: :string}}, params, [:org_name, :org_domain, :name, :email, :password])
      |> Ecto.Changeset.validate_required([:org_name, :org_domain, :name, :email, :password])
      |> Ecto.Changeset.validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must be a valid email")
      |> Ecto.Changeset.validate_length(:password, min: 8)
      |> Ecto.Changeset.validate_format(:org_domain, ~r/^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$/, message: "must be a valid domain")
    
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end


  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end