defmodule D20CharacterKeeper.CharacterHelpers do
  def modifier_form_name(f_index, m_index) do
    "character_fields_#{f_index}_modifiers_#{m_index}" |> String.to_atom
  end

  def field_name(f) do
    (f.data.name || f.source.changes.name) |> String.slice(0..2) |> String.upcase
  end

  def field_has_modifiers?(f) do
    has_in_data?   = is_list(f.data.modifiers) && length(f.data.modifiers) != 0
    has_in_source? = is_list(f.source.changes[:modifiers])
    has_in_data? || has_in_source?
  end
end
