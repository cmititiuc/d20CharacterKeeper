defmodule D20CharacterKeeper.CharacterIntegrationTest do
  use D20CharacterKeeper.ConnCase

  # Import Hound helpers
  use Hound.Helpers

  # Start a Hound session
  hound_session

  test "editing modifiers preserves table structure", %{conn: _conn} do
    no_of_cells = 3
    no_of_cells_with_modifier = 6
    no_of_abilities = 6
    no_of_modifiers_per_ability = 2

    navigate_to "/characters/new"

    # make sure the number of cells per row is accurate
    rows = find_all_elements(:css, "table#ability-scores-form tbody tr")
    assert length(rows) == no_of_abilities
    for row <- rows do
      cells = find_all_within_element(row, :css, "td")
      assert length(cells) == no_of_cells
    end

    # add some modifiers
    links = find_all_elements(:link_text, "+")
    for link <- links do
      for _ <- Range.new(1, no_of_modifiers_per_ability), do: link |> click
    end

    # make sure the number of cells per row is accurate
    rows = find_all_elements(:css, "table#ability-scores-form tbody tr")
    assert length(rows) == no_of_abilities * no_of_modifiers_per_ability
    for row <- rows do
      cells = find_all_within_element(row, :css, "td")
      assert length(cells) == no_of_cells_with_modifier
    end

    # remove modifiers
    links = find_all_elements(:link_text, "−")
    for link <- links, do: link |> click

    # make sure the number of cells per row is accurate
    rows = find_all_elements(:css, "table#ability-scores-form tbody tr")
    assert length(rows) == no_of_abilities
    for row <- rows do
      cells = find_all_within_element(row, :css, "td")
      assert length(cells) == no_of_cells
    end
  end

  test "new character form structure and validations", %{conn: _conn} do
    navigate_to "/characters/new"

    add_mod_selector = "table#ability-scores-form tbody tr td a.add-modifier"
    add_mod_trigs = find_all_elements(:css, add_mod_selector)
    [add_str, add_dex, _add_con, add_int, _add_wis, add_cha] = add_mod_trigs

    add_str |> click
    add_str |> click
    add_str |> click
    add_dex |> click
    add_int |> click
    add_int |> click
    add_cha |> click

    assert_abil_score_table

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert_abil_score_table(%{failed_validation: true, edit: false})
    assert visible_page_text =~
      "Oops, something went wrong! Please check the errors below."

    fill_form

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert visible_page_text =~ "Character created successfully."

    find_element(:link_text, "Edit") |> click

    assert_abil_score_table(%{failed_validation: false, edit: true})
  end

  defp assert_abil_score_table(
    %{failed_validation: failed_validation, edit: edit}
      \\ %{failed_validation: false, edit: false}
  ) do
    [ str_row_1, str_row_2, str_row_3,
      dex_row,
      con_row,
      int_row_1, int_row_2,
      wis_row,
      cha_row
    ] =
      find_all_elements(:css, "table#ability-scores-form tbody tr")

    str_row_1 |> assert_abil_score_with_mod_row("strength", failed_validation, edit)
    str_row_2 |> assert_mod_row(failed_validation, edit)
    str_row_3 |> assert_mod_row(failed_validation, edit)
    dex_row   |> assert_abil_score_with_mod_row("dexterity", failed_validation, edit)
    con_row   |> assert_abil_score_row("constitution", failed_validation)
    int_row_1 |> assert_abil_score_with_mod_row("intelligence", failed_validation, edit)
    int_row_2 |> assert_mod_row(failed_validation, edit)
    wis_row   |> assert_abil_score_row("wisdom", failed_validation)
    cha_row   |> assert_abil_score_with_mod_row("charisma", failed_validation, edit)
  end

  defp assert_abil_score_row(row, abil, failed_val) do
    cells = find_all_within_element(row, :css, "td")
    [cell1, cell2, cell3] = cells

    assert cell1 |> visible_text == abil |> String.slice(0..2) |> String.upcase

    find_within_element(cell2, :css, "input[type=hidden][value=#{abil}]")
    find_within_element(cell2, :css, "input[type=number]")
    if failed_val, do: assert visible_text(cell2) =~ "can't be blank"

    find_within_element(cell3, :css, "a.add-modifier")
    find_within_element(cell3, :link_text, "+")
  end

  defp assert_abil_score_with_mod_row(row, abil, failed_val, edit) do
    cells = find_all_within_element(row, :css, "td")
    [cell1, cell2, cell3, cell4, cell5, cell6] = cells

    assert cell1 |> visible_text == abil |> String.slice(0..2) |> String.upcase

    find_within_element(cell2, :css, "input[type=hidden][value=#{abil}]")
    find_within_element(cell2, :css, "input[type=number]")
    if failed_val, do: assert visible_text(cell2) =~ "can't be blank"

    find_within_element(cell3, :css, "input[type=number]")
    if failed_val, do: assert visible_text(cell3) =~ "can't be blank"

    find_within_element(cell4, :css, "input[type=text]")
    if failed_val, do: assert visible_text(cell4) =~ "can't be blank"

    if edit do
      find_within_element(cell5, :css, "input[type=checkbox]")
      assert visible_text(cell5) =~ "Delete?"
    else
      find_within_element(cell5, :css, "a.remove-modifier")
      find_within_element(cell5, :link_text, "−")
    end

    find_within_element(cell6, :css, "a.add-modifier")
    find_within_element(cell6, :link_text, "+")
  end

  defp assert_mod_row(row, failed_val, edit) do
    cells = find_all_within_element(row, :css, "td")
    [cell1, cell2, cell3, cell4, cell5, cell6] = cells

    assert cell1 |> inner_text == ""
    assert cell2 |> inner_text == ""

    find_within_element(cell3, :css, "input[type=number]")
    if failed_val, do: assert visible_text(cell3) =~ "can't be blank"

    find_within_element(cell4, :css, "input[type=text]")
    if failed_val, do: assert visible_text(cell4) =~ "can't be blank"

    if edit do
      find_within_element(cell5, :css, "input[type=checkbox]")
      assert visible_text(cell5) =~ "Delete?"
    else
      find_within_element(cell5, :css, "a.remove-modifier")
      find_within_element(cell5, :link_text, "−")
    end

    assert cell6 |> inner_text == ""
  end

  defp fill_form do
    fill_field({:id, "character_name"}, "Batman")
    fill_field({:id, "character_player"}, "Adam West")
    fill_field({:id, "character_character_level"}, "1")

    fill_field({:id, "character_fields_0_value"}, "10")
    fill_field({:id, "character_fields_1_value"}, "11")
    fill_field({:id, "character_fields_2_value"}, "12")
    fill_field({:id, "character_fields_3_value"}, "13")
    fill_field({:id, "character_fields_4_value"}, "14")
    fill_field({:id, "character_fields_5_value"}, "15")

    fill_field({:id, "character_fields_0_modifiers_0_value"}, "1")
    fill_field({:id, "character_fields_0_modifiers_1_value"}, "2")
    fill_field({:id, "character_fields_0_modifiers_2_value"}, "3")
    fill_field({:id, "character_fields_1_modifiers_0_value"}, "4")
    fill_field({:id, "character_fields_3_modifiers_0_value"}, "5")
    fill_field({:id, "character_fields_3_modifiers_1_value"}, "6")
    fill_field({:id, "character_fields_5_modifiers_0_value"}, "7")

    fill_field({:id, "character_fields_0_modifiers_0_description"}, "one")
    fill_field({:id, "character_fields_0_modifiers_1_description"}, "two")
    fill_field({:id, "character_fields_0_modifiers_2_description"}, "three")
    fill_field({:id, "character_fields_1_modifiers_0_description"}, "four")
    fill_field({:id, "character_fields_3_modifiers_0_description"}, "five")
    fill_field({:id, "character_fields_3_modifiers_1_description"}, "six")
    fill_field({:id, "character_fields_5_modifiers_0_description"}, "seven")
  end
end
