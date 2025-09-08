defmodule FlusomailWeb.PageController do
  use FlusomailWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
