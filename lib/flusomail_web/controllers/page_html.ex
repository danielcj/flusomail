defmodule FlusomailWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use FlusomailWeb, :html

  embed_templates "page_html/*"

  def home(assigns) do
    ~H"""
    <Layouts.public flash={@flash} current_user={@current_scope && @current_scope.user}>
      <div class="flex items-center justify-center flex-1">
        <div class="text-center">
          <h1 class="text-6xl font-bold mb-8 text-base-content">FlusoMail</h1>
          <p class="text-xl text-base-content/70 mb-8">
            Reliable email delivery for your applications
          </p>
          <div class="space-x-4">
            <a href="/users/log-in" class="btn btn-primary btn-lg">Log In</a>
            <a href="/users/register" class="btn btn-outline btn-lg">Create Account</a>
          </div>
        </div>
      </div>
    </Layouts.public>
    """
  end
end
