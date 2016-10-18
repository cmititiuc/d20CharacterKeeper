defmodule D20CharacterKeeper.CharacterHelpers do
  def modifier_form_name(f_index, m_index) do
    "character_fields_#{f_index}_modifiers_#{m_index}" |> String.to_atom
  end

  def field_name(f) do
    (f.data.name || f.source.changes.name) |> String.slice(0..2) |> String.upcase
  end
end
