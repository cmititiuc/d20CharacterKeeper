import $ from "jquery"

function ability_name_fields() {
  return [
    'input[value=strength]',
    'input[value=dexterity]',
    'input[value=constitution]',
    'input[value=intelligence]',
    'input[value=wisdom]',
    'input[value=charisma]',
  ]
}

function modifier_cells() {
  return (
    '<td style="padding: 3px;">' +
    '<input class="form-control" id="" name="" type="number"></td>' +
    '<td style="padding: 3px;">' +
    '<input class="form-control" id="" name="" type="text"></td>' +
    '<td style="vertical-align: top; padding-top: 6px; font-size: larger">' +
    '<a href="#" class="remove-modifier">−</a></td>'
  )
}

function new_row(cells) {
  return ('<tr><td></td><td></td>' + cells() + '</tr>')
}

function find_last_modifier_row_for(row) {
  // find the row before the next row that contains an ability score
  // (demarcated by the "+" action link) or the last row if there are none
  while (row.next().length && row.next().children('td').last().text() != '+') {
    row = row.next()
  }
  return (row)
}

function renumber_modifiers() {
  $('#modifiers .form-group:even').each(function(i) {
    $(this).children('label').attr('for', 'field_modifiers_' + i + '_value')
    $(this).children('input')
      .attr('id', 'field_modifiers_' + i + '_value')
      .attr('name', 'field[modifiers][' + i + '][value]')
  })
  $('#modifiers .form-group:odd').each(function(i) {
    $(this).children('label').attr('for', 'field_modifiers_' + i + '_description')
    $(this).children('input')
      .attr('id', 'field_modifiers_' + i + '_description')
      .attr('name', 'field[modifiers][' + i + '][description]')
  })
}

function remove_modifier(e) {
  e.preventDefault()
  // do any of the cells in this row have an ability score field?
  var row_contains_ability_score =
    $(this).parent().siblings().children(ability_name_fields().join(', ')).length

  if (row_contains_ability_score) {
    // only delete the cells that contain the modifier fields
    var parent = $(this).parent()
    parent.prev().remove()
    parent.prev().remove()
    parent.remove()
  } else {
    // delete the whole row
    $(this).parents('tr').remove()
  }

  // renumber_modifiers()
}

function add_modifier(e) {
  e.preventDefault()
  var parent_cell = $(this).parent()
  var previous_cell_contains_ability_score =
    parent_cell.prev().children(ability_name_fields().join(', ')).length

  if (previous_cell_contains_ability_score) {
    parent_cell.before(modifier_cells)
  } else {
    var parent_row = $(this).parents('tr')
    find_last_modifier_row_for(parent_row).after(new_row(modifier_cells))
  }

  // renumber_modifiers()
}

function run() {
  $(document).on('click', '.remove-modifier', remove_modifier)
  $(document).ready(function() { $('.add-modifier').on('click', add_modifier) })
}

export var Characters = { run: run }
