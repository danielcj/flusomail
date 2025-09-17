defmodule FlusomailWeb.Components.CommandPalette do
  @moduledoc """
  Dynamic command palette component with context-aware action registration.

  This component provides a modern command palette that can be triggered with Cmd+K.
  It supports both global navigation actions and context-specific actions that can be
  registered dynamically based on the current page/context.

  ## Usage

  Basic usage in layout:
      <.command_palette current_scope={@current_scope} />

  With context-specific actions:
      <.command_palette current_scope={@current_scope} context_actions={@context_actions} />

  ## Action Structure

  Actions should be maps with the following structure:
      %{
        id: "unique-action-id",
        title: "Action Title",
        description: "Action description",
        icon: "hero-icon-name",
        icon_color: "from-blue-500 to-blue-600",
        action: :navigate | :event,
        path: "/path/to/navigate" (for :navigate actions),
        event: "event-name" (for :event actions),
        params: %{} (for :event actions),
        section: "Navigation" | "Actions" | "Context",
        keywords: ["search", "terms"] (optional for better search)
      }
  """
  use FlusomailWeb, :html
  use Phoenix.Component

  @doc """
  Renders the command palette overlay with dynamic actions.
  """
  attr :current_scope, :map, default: nil, doc: "the current user scope"
  attr :context_actions, :list, default: [], doc: "context-specific actions"
  attr :id, :string, default: "command-palette", doc: "component id"

  def command_palette(assigns) do
    assigns =
      assign(assigns, :all_actions, build_actions(assigns.current_scope, assigns.context_actions))

    ~H"""
    <!-- Command Palette Overlay -->
    <div
      id={"#{@id}-overlay"}
      class="fixed inset-0 z-50 hidden bg-black/50 backdrop-blur-sm"
      phx-hook=".CommandPalette"
      data-testid="command-palette-overlay"
      data-actions={Jason.encode!(@all_actions)}
    >
      <div class="flex min-h-screen items-start justify-center pt-20 px-4">
        <div
          id={@id}
          class="w-full max-w-2xl transform overflow-hidden rounded-xl bg-base-100 shadow-2xl ring-1 ring-base-300/50 transition-all"
          style="animation: slideIn 0.2s ease-out;"
        >
          <!-- Search Input -->
          <div class="relative border-b border-base-300/50">
            <div class="absolute left-4 top-1/2 -translate-y-1/2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 text-base-content/50"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                />
              </svg>
            </div>
            <input
              id={"#{@id}-input"}
              type="text"
              placeholder="Search for pages, actions, or anything..."
              class="w-full bg-transparent py-4 pl-12 pr-4 text-base outline-none placeholder-base-content/50"
              autocomplete="off"
            />
            <div class="absolute right-4 top-1/2 -translate-y-1/2">
              <span class="text-xs text-base-content/40">ESC to close</span>
            </div>
          </div>
          
    <!-- Results Container -->
          <div id={"#{@id}-results"} class="max-h-96 overflow-y-auto">
            <!-- Dynamic sections will be populated by JavaScript -->
          </div>
          
    <!-- No results message -->
          <div id={"#{@id}-no-results"} class="hidden p-8 text-center">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="mx-auto h-12 w-12 text-base-content/30"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
            <p class="mt-4 text-base-content/60">No results found</p>
            <p class="mt-1 text-sm text-base-content/40">
              Try different keywords or browse available actions
            </p>
          </div>
          
    <!-- Footer with shortcuts -->
          <div class="border-t border-base-300/30 px-4 py-3 bg-base-200/30">
            <div class="flex items-center justify-between text-xs text-base-content/50">
              <div class="flex items-center space-x-4">
                <div class="flex items-center space-x-1">
                  <kbd class="px-1.5 py-0.5 text-xs bg-base-300/50 border border-base-300 rounded">
                    ↑
                  </kbd>
                  <kbd class="px-1.5 py-0.5 text-xs bg-base-300/50 border border-base-300 rounded">
                    ↓
                  </kbd>
                  <span>to navigate</span>
                </div>
                <div class="flex items-center space-x-1">
                  <kbd class="px-1.5 py-0.5 text-xs bg-base-300/50 border border-base-300 rounded">
                    ↵
                  </kbd>
                  <span>to select</span>
                </div>
              </div>
              <div class="flex items-center space-x-1">
                <kbd class="px-1.5 py-0.5 text-xs bg-base-300/50 border border-base-300 rounded">
                  ESC
                </kbd>
                <span>to close</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <style>
      @keyframes slideIn {
        from {
          opacity: 0;
          transform: translateY(-20px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }

      .command-item.selected {
        background: rgb(59 130 246 / 0.15) !important;
        border: 1px solid rgb(59 130 246 / 0.3) !important;
        border-left: 3px solid rgb(59 130 246) !important;
        box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1) !important;
        margin: 2px 0;
        position: relative;
      }

      .command-item.selected .font-medium {
        color: rgb(59 130 246) !important;
        font-weight: 600 !important;
      }

      .command-item.selected .text-sm {
        color: rgb(59 130 246 / 0.8) !important;
      }

      .command-item.selected .w-8 {
        transform: scale(1.1);
        box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1), 0 0 0 2px rgb(255 255 255 / 0.2);
      }

      .command-item.selected:hover {
        background: rgb(59 130 246 / 0.2) !important;
      }
    </style>

    <script :type={Phoenix.LiveView.ColocatedHook} name=".CommandPalette">
      export default {
        mounted() {
          this.overlay = this.el
          this.palette = this.el.querySelector(`#${this.el.id.replace('-overlay', '')}`)
          this.input = this.el.querySelector(`#${this.el.id.replace('-overlay', '')}-input`)
          this.results = this.el.querySelector(`#${this.el.id.replace('-overlay', '')}-results`)
          this.noResults = this.el.querySelector(`#${this.el.id.replace('-overlay', '')}-no-results`)

          this.selectedIndex = 0
          this.filteredActions = []
          this.allActions = []

          // Load actions from data attribute
          this.loadActions()

          // Setup event handlers
          this.setupEventHandlers()

          // Initialize display
          this.renderActions(this.allActions)
        },

        destroyed() {
          document.removeEventListener('keydown', this.handleKeyDown)
        },

        loadActions() {
          try {
            const actionsData = this.el.dataset.actions
            this.allActions = actionsData ? JSON.parse(actionsData) : []
            this.filteredActions = [...this.allActions]
          } catch (error) {
            console.error('Failed to parse command palette actions:', error)
            this.allActions = []
            this.filteredActions = []
          }
        },

        setupEventHandlers() {
          // Global keyboard handler
          this.handleKeyDown = (e) => {
            // Global Cmd+K / Ctrl+K trigger
            if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
              e.preventDefault()
              this.show()
              return
            }

            // Handle palette navigation only when visible
            if (!this.overlay.classList.contains('hidden')) {
              switch (e.key) {
                case 'ArrowDown':
                  e.preventDefault()
                  this.selectNext()
                  break
                case 'ArrowUp':
                  e.preventDefault()
                  this.selectPrevious()
                  break
                case 'Enter':
                  e.preventDefault()
                  this.executeSelected()
                  break
                case 'Escape':
                  e.preventDefault()
                  this.hide()
                  break
              }
            }
          }

          // Search handler
          this.handleInput = (e) => {
            const query = e.target.value.toLowerCase().trim()
            this.search(query)
          }

          // Click handlers
          this.handleOverlayClick = (e) => {
            if (e.target === this.overlay) {
              this.hide()
            }
          }

          this.handleItemClick = (e) => {
            const item = e.currentTarget
            const actionId = item.dataset.actionId
            const action = this.allActions.find(a => a.id === actionId)
            if (action) {
              this.executeAction(action)
            }
          }

          // Add event listeners
          document.addEventListener('keydown', this.handleKeyDown)
          this.input.addEventListener('input', this.handleInput)
          this.overlay.addEventListener('click', this.handleOverlayClick)
        },

        show() {
          this.overlay.classList.remove('hidden')
          this.input.focus()
          this.input.value = ''
          this.selectedIndex = 0
          this.search('') // Reset to show all actions
        },

        hide() {
          this.overlay.classList.add('hidden')
          this.input.blur()
        },

        search(query) {
          if (!query) {
            this.filteredActions = [...this.allActions]
          } else {
            this.filteredActions = this.allActions.filter(action => {
              return this.fuzzyMatch(query, this.getSearchableText(action))
            })
          }

          this.renderActions(this.filteredActions)
          this.selectedIndex = 0
          this.updateSelection()
        },

        fuzzyMatch(query, text) {
          query = query.toLowerCase()
          text = text.toLowerCase()

          let queryIndex = 0
          for (let i = 0; i < text.length && queryIndex < query.length; i++) {
            if (text[i] === query[queryIndex]) {
              queryIndex++
            }
          }
          return queryIndex === query.length
        },

        getSearchableText(action) {
          const searchableFields = [
            action.title,
            action.description,
            ...(action.keywords || [])
          ]
          return searchableFields.join(' ').toLowerCase()
        },

        renderActions(actions) {
          if (actions.length === 0) {
            this.results.innerHTML = ''
            this.noResults.classList.remove('hidden')
            return
          }

          this.noResults.classList.add('hidden')

          // Group actions by section
          const sections = this.groupBySection(actions)

          let html = ''
          for (const [sectionName, sectionActions] of Object.entries(sections)) {
            html += this.renderSection(sectionName, sectionActions)
          }

          this.results.innerHTML = html

          // Add click listeners to all items
          this.results.querySelectorAll('.command-item').forEach(item => {
            item.addEventListener('click', this.handleItemClick)
          })
        },

        groupBySection(actions) {
          return actions.reduce((sections, action) => {
            const section = action.section || 'Other'
            if (!sections[section]) {
              sections[section] = []
            }
            sections[section].push(action)
            return sections
          }, {})
        },

        renderSection(sectionName, actions) {
          const isLast = sectionName === 'Account' // Don't add border after last section
          const borderClass = isLast ? '' : 'border-b border-base-300/30'

          return `
            <div class="${borderClass} p-2">
              <div class="px-3 py-1.5 text-xs font-semibold text-base-content/50 uppercase tracking-wider">
                ${sectionName}
              </div>
              ${actions.map(action => this.renderAction(action)).join('')}
            </div>
          `
        },

        renderAction(action) {
          return `
            <div
              class="command-item flex items-center rounded-lg px-3 py-2.5 hover:bg-primary/10 cursor-pointer transition-colors duration-150"
              data-action-id="${action.id}"
            >
              <div class="flex items-center space-x-3 flex-1">
                <div class="w-8 h-8 bg-gradient-to-r ${action.icon_color || 'from-gray-500 to-gray-600'} rounded-lg flex items-center justify-center shadow-sm">
                  <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    ${this.getIconPath(action.icon)}
                  </svg>
                </div>
                <div>
                  <div class="font-medium">${action.title}</div>
                  <div class="text-sm text-base-content/60">${action.description}</div>
                </div>
              </div>
              <div class="text-xs text-base-content/40">↵</div>
            </div>
          `
        },

        getIconPath(iconName) {
          // Map of common hero icons to their SVG paths
          const iconPaths = {
            'hero-home': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />',
            'hero-envelope': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />',
            'hero-rectangle-stack': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z" />',
            'hero-users': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 515.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 919.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />',
            'hero-chart-bar': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />',
            'hero-globe-alt': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />',
            'hero-key': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1721 9z" />',
            'hero-link': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1" />',
            'hero-document-text': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />',
            'hero-user': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />',
            'hero-building-office': '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-8 0H3m2 0h6M9 7h6m-6 4h6m-6 4h6" />'
          }

          return iconPaths[iconName] || iconPaths['hero-home'] // Default to home icon
        },

        selectNext() {
          if (this.filteredActions.length === 0) return
          this.selectedIndex = (this.selectedIndex + 1) % this.filteredActions.length
          this.updateSelection()
        },

        selectPrevious() {
          if (this.filteredActions.length === 0) return
          this.selectedIndex = this.selectedIndex === 0 ? this.filteredActions.length - 1 : this.selectedIndex - 1
          this.updateSelection()
        },

        updateSelection() {
          // Remove previous selection
          this.results.querySelectorAll('.command-item').forEach(item => {
            item.classList.remove('selected')
          })

          // Add selection to current item
          const items = this.results.querySelectorAll('.command-item')
          if (items[this.selectedIndex]) {
            const selectedItem = items[this.selectedIndex]
            selectedItem.classList.add('selected')
            selectedItem.scrollIntoView({
              block: 'nearest',
              behavior: 'smooth'
            })
          }
        },

        executeSelected() {
          if (this.filteredActions[this.selectedIndex]) {
            const action = this.filteredActions[this.selectedIndex]
            this.executeAction(action)
          }
        },

        executeAction(action) {
          this.hide()

          switch (action.action) {
            case 'navigate':
              if (action.path) {
                window.location.href = action.path
              }
              break
            case 'event':
              if (action.event) {
                this.pushEvent(action.event, action.params || {})
              }
              break
            default:
              console.warn('Unknown action type:', action.action)
          }
        }
      }
    </script>
    """
  end

  @doc """
  Builds the complete action registry with global navigation and context actions.
  """
  def build_actions(current_scope, context_actions \\ []) do
    global_actions = [
      # Navigation Actions
      %{
        id: "nav-dashboard",
        title: "Dashboard",
        description: "View overview and stats",
        icon: "hero-home",
        icon_color: "from-blue-500 to-blue-600",
        action: :navigate,
        path: "/dashboard",
        section: "Navigation",
        keywords: ["dashboard", "home", "overview", "stats"]
      },
      %{
        id: "nav-flows",
        title: "Flows",
        description: "Create visual email flows",
        icon: "hero-envelope",
        icon_color: "from-blue-500 to-blue-600",
        action: :navigate,
        path: "/flows",
        section: "Navigation",
        keywords: ["flows", "campaigns", "email", "marketing", "visual", "automation"]
      },
      %{
        id: "nav-templates",
        title: "Templates",
        description: "Create and edit email templates",
        icon: "hero-rectangle-stack",
        icon_color: "from-purple-500 to-purple-600",
        action: :navigate,
        path: "/templates",
        section: "Navigation",
        keywords: ["templates", "design", "html", "editor"]
      },
      %{
        id: "nav-contacts",
        title: "Contacts",
        description: "Manage contact lists",
        icon: "hero-users",
        icon_color: "from-indigo-500 to-indigo-600",
        action: :navigate,
        path: "/contacts",
        section: "Navigation",
        keywords: ["contacts", "users", "audience", "subscribers"]
      },
      %{
        id: "nav-analytics",
        title: "Analytics",
        description: "View email performance metrics",
        icon: "hero-chart-bar",
        icon_color: "from-rose-500 to-rose-600",
        action: :navigate,
        path: "/analytics",
        section: "Navigation",
        keywords: ["analytics", "metrics", "performance", "stats", "reports"]
      },

      # Configuration Actions
      %{
        id: "config-domains",
        title: "Domains",
        description: "Configure sending domains",
        icon: "hero-globe-alt",
        icon_color: "from-cyan-500 to-cyan-600",
        action: :navigate,
        path: "/domains",
        section: "Configuration",
        keywords: ["domains", "dns", "authentication", "setup"]
      },
      %{
        id: "config-api-keys",
        title: "API Keys",
        description: "Manage API authentication",
        icon: "hero-key",
        icon_color: "from-amber-500 to-amber-600",
        action: :navigate,
        path: "/api-keys",
        section: "Configuration",
        keywords: ["api", "keys", "authentication", "tokens", "integration"]
      },
      %{
        id: "config-webhooks",
        title: "Webhooks",
        description: "Configure webhook endpoints",
        icon: "hero-link",
        icon_color: "from-emerald-500 to-emerald-600",
        action: :navigate,
        path: "/webhooks",
        section: "Configuration",
        keywords: ["webhooks", "callbacks", "notifications", "endpoints"]
      },
      %{
        id: "logs",
        title: "Email Logs",
        description: "View delivery logs and events",
        icon: "hero-document-text",
        icon_color: "from-slate-500 to-slate-600",
        action: :navigate,
        path: "/logs",
        section: "Configuration",
        keywords: ["logs", "delivery", "events", "history", "debug"]
      }
    ]

    # Add account-specific actions if user is present
    account_actions =
      if current_scope do
        [
          %{
            id: "account-settings",
            title: "Account Settings",
            description: current_scope.user.email,
            icon: "hero-user",
            icon_color: "from-primary to-secondary",
            action: :navigate,
            path: "/users/settings",
            section: "Account",
            keywords: ["account", "settings", "profile", "user"]
          }
        ] ++
          if current_scope.organization do
            [
              %{
                id: "org-settings",
                title: "Organization Settings",
                description: current_scope.organization.name,
                icon: "hero-building-office",
                icon_color: "from-primary to-secondary",
                action: :navigate,
                path: "/organizations/#{current_scope.organization.id}",
                section: "Account",
                keywords: ["organization", "settings", "team", "billing"]
              }
            ]
          else
            []
          end
      else
        []
      end

    # Combine all actions
    global_actions ++ account_actions ++ context_actions
  end

  @doc """
  Helper to create context-specific actions for different pages.

  ## Examples

      # For campaign page
      context_actions = CommandPalette.context_actions("campaigns", [
        %{id: "create-campaign", title: "New Campaign", ...},
        %{id: "duplicate-campaign", title: "Duplicate Campaign", ...}
      ])

      # For template editor
      context_actions = CommandPalette.context_actions("templates", [
        %{id: "save-template", title: "Save Template", event: "save", ...}
      ])
  """
  def context_actions(context, actions) do
    Enum.map(actions, fn action ->
      action
      |> Map.put(:section, "#{String.capitalize(context)} Actions")
      |> Map.put_new(:keywords, [context])
    end)
  end
end
