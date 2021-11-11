defmodule TerribleWeb.PageController do
  use TerribleWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
