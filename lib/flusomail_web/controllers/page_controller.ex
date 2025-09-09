defmodule FlusomailWeb.PageController do
  use FlusomailWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_scope] do
      redirect(conn, to: ~p"/home")
    else
      render(conn, :home, layout: false)
    end
  end
end
