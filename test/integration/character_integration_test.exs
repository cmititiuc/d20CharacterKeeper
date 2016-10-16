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
      for _ <- Range.new(1, no_of_modifiers_per_ability) do
        link |> click
      end
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
end
