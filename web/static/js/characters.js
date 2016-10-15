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

// TODO: REFACTOR
function renumber_modifiers() {
  var ability_field_cells = $('table').eq(1).find('tbody tr > td:nth-child(2)')
  var ability_scores_fields = ability_field_cells.children('.form-control')

  ability_scores_fields.each(function(index, field) {
    var first_modifier_value_field =
      $(this).parents('tr').find('> td:nth-child(3)').children('input[type=number]')
    var first_modifier_description_field =
      $(this).parents('tr').find('> td:nth-child(4)').children('input[type=text]')

    if (first_modifier_value_field.length) {
      first_modifier_value_field
        .attr('id', 'character_fields_' + index + '_modifiers_0_value')
        .attr('name', 'character[fields][' + index + '][modifiers][0][value]')
      first_modifier_description_field
        .attr('id', 'character_fields_' + index + '_modifiers_0_description')
        .attr('name', 'character[fields][' + index + '][modifiers][0][description]')

      console.log([index, field.name], [0, first_modifier_value_field[0].name])
    } else {
      console.log([index, field.name])
    }
    var row = $(this).parents('tr')
    var row_contains_ability_score = function(row) {
      return row.children('td').children(ability_name_fields().join(', ')).length
    }

    var mod_index = 1;
    while (row.next().length && !row_contains_ability_score(row.next())) {
      row = row.next()
      row.children('td').children('input[type=number]').each(function(j, field) {
        $(field)
          .attr('id', 'character_fields_' + index + '_modifiers_' + mod_index + '_value')
          .attr('name', 'character[fields][' + index + '][modifiers][' + mod_index + '][value]')
        console.log(' ', [index + 1, field.name])
      })
      row.children('td').children('input[type=text]').each(function(j, field) {
        $(field)
          .attr('id', 'character_fields_' + index + '_modifiers_' + mod_index + '_description')
          .attr('name', 'character[fields][' + index + '][modifiers][' + mod_index + '][description]')
        console.log(' ', [index + 1, field.name])
      })
      mod_index++;
    }
  })
  console.log("\n\n\n")
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

  renumber_modifiers()
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

  renumber_modifiers()
}

function run() {
  $(document).on('click', '.remove-modifier', remove_modifier)
  $(document).ready(function() { $('.add-modifier').on('click', add_modifier) })
}

export var Characters = { run: run }
