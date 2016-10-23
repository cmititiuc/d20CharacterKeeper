defmodule D20CharacterKeeper.CharacterView do
  use D20CharacterKeeper.Web, :view

  def render("scripts.html", _assigns) do
    ~s{<script>require("web/static/js/characters").AbilityScores.run()</script>}
    |> raw
  end
end
