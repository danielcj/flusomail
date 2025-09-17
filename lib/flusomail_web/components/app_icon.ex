defmodule FlusomailWeb.Components.AppIcon do
  @moduledoc """
  Centralized icon component for consistent icon usage across the app.

  This component provides a unified way to use icons throughout the application,
  making it easy to maintain consistency and reuse common icons.

  ## Usage

      <.app_icon name="flows" class="h-4 w-4" />
      <.app_icon name="dashboard" class="h-5 w-5 text-blue-500" />
      <.app_icon name="sparkles" class="h-6 w-6" color="blue" />

  ## Available Icons

  - `flows` - Sparkles icon for the Flow system
  - `dashboard` - Home icon for dashboard
  - `campaigns` - Envelope icon (legacy)
  - `templates` - Rectangle stack icon
  - `contacts` - Users icon
  - `analytics` - Chart bar icon
  - `domains` - Globe icon
  - `api_keys` - Key icon
  - `webhooks` - Link icon
  - `logs` - Document text icon
  - `user` - User icon
  - `organization` - Building office icon
  - `sparkles` - Sparkles icon (alias for flows)
  """
  use Phoenix.Component

  @icon_paths %{
    # Navigation icons
    "flows" =>
      "M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 00-2.456 2.456z",
    "sparkles" =>
      "M9.813 15.904L9 18.75l-.813-2.846a4.5 4.5 0 00-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 003.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 003.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 00-3.09 3.09zM18.259 8.715L18 9.75l-.259-1.035a3.375 3.375 0 00-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 002.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 002.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 00-2.456 2.456z",
    "dashboard" =>
      "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6",
    "campaigns" =>
      "M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z",
    "templates" =>
      "M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z",
    "contacts" =>
      "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 515.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 919.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z",
    "analytics" =>
      "M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z",
    "domains" =>
      "M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9",
    "api_keys" =>
      "M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1721 9z",
    "webhooks" =>
      "M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1",
    "logs" =>
      "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z",
    "user" => "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z",
    "organization" =>
      "M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-8 0H3m2 0h6M9 7h6m-6 4h6m-6 4h6"
  }

  @color_classes %{
    "blue" => "from-blue-500 to-blue-600",
    "green" => "from-green-500 to-green-600",
    "purple" => "from-purple-500 to-purple-600",
    "indigo" => "from-indigo-500 to-indigo-600",
    "rose" => "from-rose-500 to-rose-600",
    "cyan" => "from-cyan-500 to-cyan-600",
    "amber" => "from-amber-500 to-amber-600",
    "emerald" => "from-emerald-500 to-emerald-600",
    "slate" => "from-slate-500 to-slate-600",
    "primary" => "from-primary to-secondary"
  }

  @doc """
  Renders an application icon.

  ## Attributes

  - `name` - Required. The icon name (see module docs for available icons)
  - `class` - Optional. CSS classes for the SVG element
  - `color` - Optional. Predefined color for the icon container background
  - `container` - Optional. Whether to wrap in a colored container (default: false)
  - `container_class` - Optional. Additional classes for the container

  ## Examples

      # Simple icon
      <.app_icon name="flows" class="h-4 w-4" />

      # Icon with colored container (like in sidebar)
      <.app_icon name="flows" class="h-4 w-4 text-white" color="blue" container={true} />

      # Icon with custom container classes
      <.app_icon name="dashboard" class="h-4 w-4 text-white"
                 container={true} container_class="w-8 h-8 rounded-lg shadow-sm"
                 color="blue" />
  """
  attr :name, :string, required: true, doc: "the icon name"
  attr :class, :string, default: "h-5 w-5", doc: "CSS classes for the SVG"
  attr :color, :string, default: nil, doc: "predefined color for container background"
  attr :container, :boolean, default: false, doc: "whether to wrap in colored container"

  attr :container_class, :string,
    default: "w-8 h-8 rounded-lg flex items-center justify-center shadow-sm",
    doc: "container CSS classes"

  def app_icon(assigns) do
    path = Map.get(@icon_paths, assigns.name, @icon_paths["flows"])

    color_class =
      if assigns.color,
        do: Map.get(@color_classes, assigns.color, @color_classes["blue"]),
        else: nil

    assigns = assign(assigns, :path, path) |> assign(:color_class, color_class)

    ~H"""
    <%= if @container do %>
      <div class={[@container_class, @color_class && "bg-gradient-to-r #{@color_class}"]}>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class={@class}
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d={@path}
          />
        </svg>
      </div>
    <% else %>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class={@class}
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d={@path}
        />
      </svg>
    <% end %>
    """
  end
end
