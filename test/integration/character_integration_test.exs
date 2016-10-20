defmodule D20CharacterKeeper.CharacterIntegrationTest do
  use D20CharacterKeeper.ConnCase, async: true

  # Import Hound helpers
  use Hound.Helpers

  # Start a Hound session
  hound_session

  test "editing modifiers preserves table structure" do
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

  test "new character form structure is correct" do
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

    [ str_row_1, str_row_2, str_row_3,
      dex_row,
      con_row,
      int_row_1, int_row_2,
      wis_row,
      cha_row
    ] =
      find_all_elements(:css, "table#ability-scores-form tbody tr")

    assert_abil_score_with_mod_row(str_row_1, "strength")
    assert_mod_row(str_row_2)
    assert_mod_row(str_row_3)
    assert_abil_score_with_mod_row(dex_row, "dexterity")
    assert_abil_score_row(con_row, "constitution")
    assert_abil_score_with_mod_row(int_row_1, "intelligence")
    assert_mod_row(int_row_2)
    assert_abil_score_row(wis_row, "wisdom")
    assert_abil_score_with_mod_row(cha_row, "charisma")
  end

  test "failed validation" do
    navigate_to "/characters/new"

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert visible_page_text =~
      "Oops, something went wrong! Please check the errors below."
  end

  defp assert_abil_score_row(row, abil) do
    cells = find_all_within_element(row, :css, "td")
    [cell1, cell2, cell3] = cells

    assert cell1 |> visible_text == abil |> String.slice(0..2) |> String.upcase
    find_within_element(cell2, :css, "input[type=hidden][value=#{abil}]")
    find_within_element(cell3, :css, "a.add-modifier")
    find_within_element(cell3, :link_text, "+")
  end

  defp assert_abil_score_with_mod_row(row, abil) do
    cells = find_all_within_element(row, :css, "td")
    [cell1, cell2, cell3, cell4, cell5, cell6] = cells

    assert cell1 |> visible_text == abil |> String.slice(0..2) |> String.upcase
    find_within_element(cell2, :css, "input[type=hidden][value=#{abil}]")
    find_within_element(cell2, :css, "input[type=number]")
    find_within_element(cell3, :css, "input[type=number]")
    find_within_element(cell4, :css, "input[type=text]")
    find_within_element(cell5, :css, "a.remove-modifier")
    find_within_element(cell5, :link_text, "−")
    find_within_element(cell6, :css, "a.add-modifier")
    find_within_element(cell6, :link_text, "+")
  end

  defp assert_mod_row(row) do
    cells = find_all_within_element(row, :css, "td")
    [cell1, cell2, cell3, cell4, cell5, cell6] = cells

    assert cell1 |> inner_text == ""
    assert cell2 |> inner_text == ""
    find_within_element(cell3, :css, "input[type=number]")
    find_within_element(cell4, :css, "input[type=text]")
    find_within_element(cell5, :css, "a.remove-modifier")
    find_within_element(cell5, :link_text, "−")
    assert cell6 |> inner_text == ""
  end
end
