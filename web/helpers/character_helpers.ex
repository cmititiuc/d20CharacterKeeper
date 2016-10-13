defmodule D20CharacterKeeper.CharacterHelpers do
  def modifier_form_name(f_index, m_index) do
    "character_fields_#{f_index}_modifiers_#{m_index}" |> String.to_atom
  end
end
