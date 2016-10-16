defmodule D20CharacterKeeper.SampleTest do
  use D20CharacterKeeper.ConnCase

  # Import Hound helpers
  use Hound.Helpers
  require Apex
  require IEx

  # Start a Hound session
  hound_session

  test "GET /" do
    navigate_to "/characters/new"

    first_row = find_element(:css, "#ability-scores-form tbody tr")
    row_cells = find_all_within_element(first_row, :css, "td")
    assert length(row_cells) == 3

    # check that every row has just 3 cells

    # click the link
    add_modifier_link = find_element(:link_text, "+")
    click(add_modifier_link)

    first_row = find_element(:css, "#ability-scores-form tbody tr")
    row_cells = find_all_within_element(first_row, :css, "td")
    assert length(row_cells) == 6

    # check that every other row has just 3 cells
  end
end
