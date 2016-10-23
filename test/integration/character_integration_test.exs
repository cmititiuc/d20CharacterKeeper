defmodule D20CharacterKeeper.CharacterIntegrationTest do
  use D20CharacterKeeper.ConnCase

  alias D20CharacterKeeper.Character
  alias D20CharacterKeeper.Field
  alias D20CharacterKeeper.Modifier

  # Import Hound helpers
  use Hound.Helpers

  # Start a Hound session
  hound_session

  # TODO refactor
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

  test "new form" do
    navigate_to "/characters/new"

    add_modifiers

    assert_abil_score_table
  end

  test "new form failed validation" do
    navigate_to "/characters/new"

    add_modifiers

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert_abil_score_table(failed_validation: true, edit: false)
    assert visible_page_text =~
      "Oops, something went wrong! Please check the errors below."
  end

  test "new character", %{conn: _conn} do
    navigate_to "/characters/new"

    add_modifiers
    fill_form

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert visible_page_text =~ "Character created successfully."
  end

  test "edit form" do
    character = generate_character
    navigate_to "/characters/#{character.id}/edit"

    assert_abil_score_table(failed_validation: false, edit: true)
  end

  test "edit form failed validation" do
    character = generate_character
    navigate_to "/characters/#{character.id}/edit"

    fields = find_all_elements(:css, "input[type=text], input[type=number]")
    for f <- fields, do: clear_field(f)

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert visible_page_text =~
      "Oops, something went wrong! Please check the errors below."
    assert_abil_score_table(failed_validation: true, edit: true)
  end

  test "edit character", %{conn: _conn} do
    character = generate_character
    navigate_to "/characters/#{character.id}/edit"

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert visible_page_text =~ "Character updated successfully."
  end

  # TODO refactor
  test "delete modifier", %{conn: _conn} do
    character = generate_character
    navigate_to "/characters/#{character.id}/edit"

    add_dex = get_mod_trigs(:dex)
    add_dex |> click

    row = find_element(:css, "table#ability-scores-form tbody tr:nth-child(9)")
    value_field = find_within_element(row, :css, "td input[type=number]")
    fill_field(value_field, "1")
    desc_field =  find_within_element(row, :css, "td input[type=text]")
    fill_field(desc_field, "desc")

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert visible_page_text =~ "Character updated successfully."

    navigate_to "/characters/#{character.id}/edit"

    row = find_element(:css, "table#ability-scores-form tbody tr:nth-child(8)")
    find_within_element(row, :css, "td input[type=checkbox]") |> click

    # submit form
    submit = find_element(:css, "button[type=submit]")
    submit |> click

    assert visible_page_text =~ "Character updated successfully."

    navigate_to "/characters/#{character.id}/edit"
    assert_abil_score_table(edit: true)
  end

  test "remove modifier from an ability score row" do
    character = generate_character
    navigate_to "/characters/#{character.id}/edit"

    add_con = get_mod_trigs(:con)
    add_con |> click
    add_con |> click
    find_element(:link_text, "−") |> click

    con_row = find_element(:css, "table#ability-scores-form tr:nth-child(9)")
    con_row |> assert_abil_score_with_mod_row("constitution", false, false)
  end

  defp assert_abil_score_table(opts \\ nil) do
    [ str_row_1, str_row_2, str_row_3,
      dex_row,
      con_row,
      int_row_1, int_row_2,
      wis_row,
      cha_row
    ] = find_all_elements(:css, "table#ability-scores-form tbody tr")

    failed_val = opts[:failed_validation]
    edit = opts[:edit]

    str_row_1 |> assert_abil_score_with_mod_row("strength", failed_val, edit)
    str_row_2 |> assert_mod_row(failed_val, edit)
    str_row_3 |> assert_mod_row(failed_val, edit)
    dex_row   |> assert_abil_score_with_mod_row("dexterity", failed_val, edit)
    con_row   |> assert_abil_score_row("constitution", failed_val)
    int_row_1 |> assert_abil_score_with_mod_row("intelligence", failed_val, edit)
    int_row_2 |> assert_mod_row(failed_val, edit)
    wis_row   |> assert_abil_score_row("wisdom", failed_val)
    cha_row   |> assert_abil_score_with_mod_row("charisma", failed_val, edit)
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

  defp generate_character do
    Repo.insert!(
      %Character{name: "Bob", player: "Joe", character_level: 1, fields: [
        %Field{name: "strength", value: 1, modifiers: [
          %Modifier{value: 1, description: "desc"},
          %Modifier{value: 2, description: "desc"},
          %Modifier{value: 3, description: "desc"}
        ]},
        %Field{name: "dexterity", value: 2, modifiers: [
          %Modifier{value: 4, description: "desc"}
        ]},
        %Field{name: "constitution", value: 3},
        %Field{name: "intelligence", value: 4, modifiers: [
          %Modifier{value: 5, description: "desc"},
          %Modifier{value: 6, description: "desc"}
        ]},
        %Field{name: "wisdom", value: 5},
        %Field{name: "charisma", value: 6, modifiers: [
          %Modifier{value: 7, description: "desc"}
        ]}
      ]}
    )
  end

  defp add_modifiers do
    trigs = get_mod_trigs

    [ trigs[:str], trigs[:str], trigs[:str],
      trigs[:dex],
      trigs[:int], trigs[:int],
      trigs[:cha]
    ] |> Enum.map(&(click(&1)))
  end

  # use:
  #   %{con: add_con, str: add_str} = get_mod_trigs([:con, :str])
  #   add_con |> click
  #   add_str |> click
  #
  #   trigs = get_mod_trigs
  #   trigs[:con] |> click
  #   trigs[:int] |> click
  #
  #   get_mod_trigs(:con) |> click
  defp get_mod_trigs(abilities \\ nil) do
    add_mod_selector = "table#ability-scores-form tbody tr td a.add-modifier"
    [str, dex, con, int, wis, cha] = find_all_elements(:css, add_mod_selector)
    add_links = [str: str, dex: dex, con: con, int: int, wis: wis, cha: cha]

    case abilities do
      _abilites when is_list(abilities) and length(abilities) > 1 ->
        Enum.reduce(abilities, %{}, fn abil, acc ->
          Map.merge(%{abil => add_links[abil]}, acc)
        end)
      ability when not is_nil(ability) and is_atom(ability) ->
        add_links[ability]
      _ ->
        Enum.into(add_links, %{})
    end
  end
end
