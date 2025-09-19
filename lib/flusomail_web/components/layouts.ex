defmodule FlusomailWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use FlusomailWeb, :html

  import FlusomailWeb.Components.AppIcon

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders the auth layout for registration and login pages.

  This provides a minimal header with theme toggle and flusomail.com link,
  and centers the content for auth forms.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  slot :inner_block, required: true

  def auth(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={get_csrf_token()} />
        <.live_title default="Flusomail" suffix=" · Phoenix Framework">
          {assigns[:page_title]}
        </.live_title>
        <link phx-track-static rel="stylesheet" href={~p"/assets/css/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}>
        </script>
        <script>
          (() => {
            const setTheme = (theme) => {
              if (theme === "system") {
                localStorage.removeItem("phx:theme");
                document.documentElement.removeAttribute("data-theme");
              } else {
                localStorage.setItem("phx:theme", theme);
                document.documentElement.setAttribute("data-theme", theme);
              }
            };
            if (!document.documentElement.hasAttribute("data-theme")) {
              setTheme(localStorage.getItem("phx:theme") || "system");
            }
            window.addEventListener("storage", (e) => e.key === "phx:theme" && setTheme(e.newValue || "system"));

            window.addEventListener("phx:set-theme", (e) => setTheme(e.target.dataset.phxTheme));
          })();
        </script>
      </head>
      <body class="bg-base-100">
        <header class="navbar px-4 sm:px-6 lg:px-8">
          <div class="flex-1">
            <a href="https://flusomail.com" class="text-xl font-bold">FlusoMail</a>
          </div>
          <div class="flex-none">
            <.theme_toggle />
          </div>
        </header>

        <main class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
          <div class="max-w-md w-full space-y-8">
            <.flash_group flash={@flash} />
            {render_slot(@inner_block)}
          </div>
        </main>
      </body>
    </html>
    """
  end

  @doc """
  Renders the main application layout with sidebar navigation.

  This layout provides the main app interface with:
  - Sidebar navigation with organization context
  - Mobile-responsive drawer navigation
  - Flash messages and user menu

  ## Examples

      <Layouts.app flash={@flash} current_scope={@current_scope}>
        <h1>Page Content</h1>
      </Layouts.app>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current user scope with optional organization"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <!-- Command Palette -->
    <FlusomailWeb.Components.CommandPalette.command_palette current_scope={@current_scope} />

    <div class="drawer lg:drawer-open">
      <input id="drawer-toggle" type="checkbox" class="drawer-toggle" />

      <div class="drawer-content flex flex-col">
        <!-- Enhanced Top navbar for mobile -->
        <div class="navbar bg-gradient-to-r from-primary/10 to-secondary/10 backdrop-blur-sm border-b border-primary/20 lg:hidden shadow-sm">
          <div class="flex-none">
            <label
              for="drawer-toggle"
              class="btn btn-square btn-ghost drawer-button hover:bg-primary/10"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                class="inline-block w-5 h-5 stroke-current"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                >
                </path>
              </svg>
            </label>
          </div>
          <div class="flex-1">
            <a href={~p"/dashboard"} class="btn btn-ghost text-xl font-bold text-primary">
              <span class="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                FlusoMail
              </span>
            </a>
          </div>
          <div class="flex-none">
            <div class="dropdown dropdown-end">
              <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar">
                <div class="w-8 rounded-full bg-gradient-to-r from-primary to-secondary flex items-center justify-center">
                  <span class="text-primary-content text-sm font-semibold">
                    {if @current_scope,
                      do: String.first(@current_scope.user.email) |> String.upcase(),
                      else: "U"}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Page content -->
        <main class="flex-1 overflow-y-auto">
          <.flash_group flash={@flash} />
          {render_slot(@inner_block)}
        </main>
      </div>
      
    <!-- Enhanced Sidebar -->
      <div class="drawer-side">
        <label for="drawer-toggle" class="drawer-overlay"></label>
        <aside class="w-72 min-h-full bg-gradient-to-b from-base-200 via-base-200 to-base-300/50 border-r border-base-300/50 shadow-xl">
          <!-- Enhanced Logo -->
          <div class="hidden lg:flex h-16 items-center px-6 border-b border-base-300/50 bg-gradient-to-r from-primary/5 to-secondary/5">
            <a href={~p"/dashboard"} class="flex items-center space-x-3 group">
              <div class="w-8 h-8 bg-gradient-to-r from-primary to-secondary rounded-lg flex items-center justify-center shadow-lg group-hover:shadow-xl transition-all duration-200">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5 text-primary-content"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                  />
                </svg>
              </div>
              <span class="text-xl font-bold bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
                FlusoMail
              </span>
            </a>
          </div>
          
    <!-- Enhanced Organization selector -->
          <div class="px-4 py-4 border-b border-base-300/50">
            <%= if @current_scope && @current_scope.organization do %>
              <div class="dropdown dropdown-bottom w-full">
                <div
                  tabindex="0"
                  role="button"
                  class="btn btn-ghost w-full justify-between hover:bg-primary/10 transition-colors duration-200 group"
                >
                  <div class="flex items-center space-x-3">
                    <div class="w-6 h-6 bg-gradient-to-r from-primary to-secondary rounded-md flex items-center justify-center">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-3 w-3 text-primary-content"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-8 0H3m2 0h6M9 7h6m-6 4h6m-6 4h6"
                        />
                      </svg>
                    </div>
                    <span class="truncate font-medium">{@current_scope.organization.name}</span>
                  </div>
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 group-hover:rotate-180 transition-transform duration-200"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M19 9l-7 7-7-7"
                    />
                  </svg>
                </div>
                <ul
                  tabindex="0"
                  class="dropdown-content menu p-2 shadow-lg bg-base-100 rounded-lg w-64 z-50 border border-base-300"
                >
                  <li>
                    <.link navigate={~p"/organizations"} class="hover:bg-primary/10">
                      <span>🔄 Switch Organization</span>
                    </.link>
                  </li>
                  <li>
                    <.link
                      navigate={~p"/organizations/#{@current_scope.organization.id}"}
                      class="hover:bg-primary/10"
                    >
                      <span>⚙️ Organization Settings</span>
                    </.link>
                  </li>
                  <div class="divider my-1"></div>
                  <li>
                    <.link navigate={~p"/organizations/new"} class="hover:bg-success/10">
                      <span>➕ Create New</span>
                    </.link>
                  </li>
                </ul>
              </div>
            <% else %>
              <div class="dropdown dropdown-bottom w-full">
                <div
                  tabindex="0"
                  role="button"
                  class="btn btn-outline btn-warning w-full justify-between hover:bg-warning/10 transition-colors duration-200 group"
                >
                  <div class="flex items-center space-x-3">
                    <div class="w-6 h-6 bg-warning/20 rounded-md flex items-center justify-center">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-3 w-3 text-warning"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 14.5c-.77.833.192 2.5 1.732 2.5z"
                        />
                      </svg>
                    </div>
                    <span class="truncate font-medium text-warning">No Organization</span>
                  </div>
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 group-hover:rotate-180 transition-transform duration-200"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M19 9l-7 7-7-7"
                    />
                  </svg>
                </div>
                <ul
                  tabindex="0"
                  class="dropdown-content menu p-2 shadow-lg bg-base-100 rounded-lg w-64 z-50 border border-base-300"
                >
                  <li>
                    <.link navigate={~p"/organizations"} class="hover:bg-primary/10">
                      <span>🏢 Select Organization</span>
                    </.link>
                  </li>
                  <li>
                    <.link navigate={~p"/organizations/new"} class="hover:bg-success/10">
                      <span>➕ Create New</span>
                    </.link>
                  </li>
                  <div class="divider my-1"></div>
                  <li>
                    <.link navigate={~p"/welcome"} class="hover:bg-info/10">
                      <span>🚀 Setup Wizard</span>
                    </.link>
                  </li>
                </ul>
              </div>
            <% end %>
          </div>
          
    <!-- Enhanced Navigation menu -->
          <nav class="flex-1 px-4 py-6 space-y-2">
            <!-- Main Dashboard -->
            <.link
              navigate={~p"/dashboard"}
              class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
            >
              <div class="w-8 h-8 bg-gradient-to-r from-blue-500 to-blue-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-4 w-4 text-white"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
                  />
                </svg>
              </div>
              <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                Dashboard
              </span>
            </.link>
            
    <!-- Section: Email Management -->
            <div class="pt-6">
              <h3 class="px-3 text-xs font-semibold text-base-content/50 uppercase tracking-wider mb-3">
                Email Management
              </h3>

              <.link
                navigate={~p"/flows"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <.app_icon
                  name="flows"
                  class="h-4 w-4 text-white"
                  color="blue"
                  container={true}
                  container_class="w-8 h-8 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200"
                />
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  Flows
                </span>
              </.link>

              <.link
                navigate={~p"/templates"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <div class="w-8 h-8 bg-gradient-to-r from-purple-500 to-purple-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 text-white"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
                    />
                  </svg>
                </div>
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  Templates
                </span>
              </.link>

              <.link
                navigate={~p"/contacts"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <.app_icon
                  name="contacts"
                  class="h-4 w-4 text-white"
                  color="indigo"
                  container={true}
                  container_class="w-8 h-8 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200"
                />
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  Contacts
                </span>
              </.link>
            </div>
            
    <!-- Section: Configuration -->
            <div class="pt-6">
              <h3 class="px-3 text-xs font-semibold text-base-content/50 uppercase tracking-wider mb-3">
                Configuration
              </h3>

              <.link
                navigate={~p"/domains"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <div class="w-8 h-8 bg-gradient-to-r from-cyan-500 to-cyan-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 text-white"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"
                    />
                  </svg>
                </div>
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  Domains
                </span>
              </.link>

              <.link
                navigate={~p"/api-keys"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <div class="w-8 h-8 bg-gradient-to-r from-amber-500 to-amber-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 text-white"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1721 9z"
                    />
                  </svg>
                </div>
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  API Keys
                </span>
              </.link>

              <.link
                navigate={~p"/webhooks"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <div class="w-8 h-8 bg-gradient-to-r from-emerald-500 to-emerald-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 text-white"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
                    />
                  </svg>
                </div>
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  Webhooks
                </span>
              </.link>
            </div>
            
    <!-- Section: Analytics -->
            <div class="pt-6">
              <h3 class="px-3 text-xs font-semibold text-base-content/50 uppercase tracking-wider mb-3">
                Analytics
              </h3>

              <.link
                navigate={~p"/analytics"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <div class="w-8 h-8 bg-gradient-to-r from-rose-500 to-rose-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 text-white"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                    />
                  </svg>
                </div>
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  Analytics
                </span>
              </.link>

              <.link
                navigate={~p"/logs"}
                class="flex items-center space-x-3 px-3 py-2.5 rounded-lg hover:bg-primary/10 transition-colors duration-200 group"
              >
                <div class="w-8 h-8 bg-gradient-to-r from-slate-500 to-slate-600 rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 text-white"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                    />
                  </svg>
                </div>
                <span class="font-medium text-base-content group-hover:text-primary transition-colors duration-200">
                  Email Logs
                </span>
              </.link>
            </div>
          </nav>
          
    <!-- Enhanced User menu at bottom -->
          <div class="absolute bottom-0 w-full border-t border-base-300/50 bg-gradient-to-r from-base-200/50 to-base-300/30 p-4">
            <div class="dropdown dropdown-top w-full">
              <div
                tabindex="0"
                role="button"
                class="btn btn-ghost w-full justify-start hover:bg-primary/10 transition-colors duration-200 group"
              >
                <div class="flex items-center space-x-3 w-full">
                  <div class="w-8 h-8 bg-gradient-to-r from-primary to-secondary rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow duration-200">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-4 w-4 text-primary-content"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                      />
                    </svg>
                  </div>
                  <div class="flex-1 text-left">
                    <div class="font-medium text-sm text-base-content truncate">
                      <%= if @current_scope do %>
                        {@current_scope.user.email}
                      <% else %>
                        Account
                      <% end %>
                    </div>
                    <div class="text-xs text-base-content/60">User Settings</div>
                  </div>
                </div>
              </div>
              <ul
                tabindex="0"
                class="dropdown-content menu p-2 shadow-lg bg-base-100 rounded-lg w-64 z-50 border border-base-300 mb-2"
              >
                <li>
                  <.link
                    navigate={~p"/users/settings"}
                    class="hover:bg-primary/10 flex items-center space-x-2"
                  >
                    <span>⚙️</span><span>Account Settings</span>
                  </.link>
                </li>
                <div class="divider my-1"></div>
                <li>
                  <.link
                    href={~p"/users/log-out"}
                    method="delete"
                    class="hover:bg-error/10 text-error flex items-center space-x-2"
                  >
                    <span>🚪</span><span>Sign Out</span>
                  </.link>
                </li>
              </ul>
            </div>
          </div>
        </aside>
      </div>
    </div>
    """
  end

  @doc """
  Renders a minimal layout for onboarding flows.

  This layout provides a clean, focused interface for user onboarding
  without the complexity of the main app navigation.

  ## Examples

      <Layouts.onboarding flash={@flash}>
        <h1>Setup Step</h1>
      </Layouts.onboarding>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  slot :inner_block, required: true

  def onboarding(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 flex flex-col">
      <!-- Simple header -->
      <header class="navbar px-4 sm:px-6 lg:px-8 border-b border-base-300">
        <div class="flex-1">
          <a href="https://flusomail.com" class="text-xl font-bold">FlusoMail</a>
        </div>
        <div class="flex-none">
          <.theme_toggle />
        </div>
      </header>
      
    <!-- Main content -->
      <main class="flex-1 flex flex-col">
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  @doc """
  Renders a simple layout for public/marketing pages.

  This layout provides a clean public interface with minimal navigation,
  suitable for landing pages, pricing, documentation, etc.

  ## Examples

      <Layouts.public flash={@flash}>
        <h1>Welcome to FlusoMail</h1>
      </Layouts.public>
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :current_user, :map, default: nil, doc: "optional current user for login state"
  slot :inner_block, required: true

  def public(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 flex flex-col">
      <!-- Public header with login/register -->
      <header class="navbar px-4 sm:px-6 lg:px-8 border-b border-base-300">
        <div class="flex-1">
          <a href="/" class="text-xl font-bold">FlusoMail</a>
        </div>
        <div class="flex-none">
          <div class="flex items-center gap-4">
            <%= if @current_user do %>
              <.link navigate={~p"/dashboard"} class="btn btn-primary">Dashboard</.link>
            <% else %>
              <.link navigate={~p"/users/log-in"} class="btn btn-ghost">Log in</.link>
              <.link navigate={~p"/users/register"} class="btn btn-primary">Sign up</.link>
            <% end %>
            <.theme_toggle />
          </div>
        </div>
      </header>
      
    <!-- Main content -->
      <main class="flex-1">
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </main>
      
    <!-- Optional footer -->
      <footer class="footer footer-center p-10 bg-base-200 text-base-content">
        <div>
          <p class="font-semibold">FlusoMail</p>
          <p>© 2024 - Reliable email delivery for your applications</p>
        </div>
      </footer>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="relative flex p-0 cursor-pointer w-1/3 h-full justify-center items-center"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <div class="flex justify-center items-center w-full h-full">
          <.icon
            name="hero-computer-desktop-micro"
            class="size-4 opacity-75 hover:opacity-100"
          />
        </div>
      </button>

      <button
        class="relative flex p-0 cursor-pointer w-1/3 h-full justify-center items-center"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <div class="flex justify-center items-center w-full h-full">
          <.icon
            name="hero-sun-micro"
            class="size-4 opacity-75 hover:opacity-100"
          />
        </div>
      </button>

      <button
        class="relative flex p-0 cursor-pointer w-1/3 h-full justify-center items-center"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <div class="flex justify-center items-center w-full h-full">
          <.icon
            name="hero-moon-micro"
            class="size-4 opacity-75 hover:opacity-100"
          />
        </div>
      </button>
    </div>
    """
  end
end
