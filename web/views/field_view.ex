defmodule D20CharacterKeeper.FieldView do
  use D20CharacterKeeper.Web, :view

  def render("scripts.html", _assigns) do
    ~s{<script>require("web/static/js/fields").Fields.run()</script>}
    |> raw
  end
end
