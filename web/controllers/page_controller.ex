defmodule D20CharacterKeeper.PageController do
  use D20CharacterKeeper.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
