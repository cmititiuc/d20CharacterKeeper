import $ from "jquery"

function ability_names() {
  return(
    ['strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma']
  )
}

function ability_name_fields() {
  return (
    ability_names()
      .map(function(name, _) { return ('input[value=' + name + ']') })
  )
}

function modifier_cells() {
  return (
    '<td><input class="form-control" type="number"></td>' +
    '<td><input class="form-control" type="text"></td>' +
    '<td class="remove-modifier-container">' +
    '<a href="#" class="remove-modifier">−</a></td>'
  )
}

function new_row(cells) {
  return ('<tr><td></td><td></td>' + cells() + '<td></td></tr>')
}

function form_attr_id(i, mod_i, attr) {
  return ('character_fields_' + i + '_modifiers_' + mod_i + '_' + attr)
}

function form_attr_name(i, mod_i, attr) {
  return ('character[fields][' + i + '][modifiers][' + mod_i + '][' + attr + ']')
}

// do any of the cells in the row have an ability score field?
function row_contains_ability_score(row) {
  return row.children('td').children(ability_name_fields().join(', ')).length
}

function set_id_and_name_attrs(field, index, mod_index, attr) {
  $(field)
    .attr('id', form_attr_id(index, mod_index, attr))
    .attr('name', form_attr_name(index, mod_index, attr))
}

function set_mod_attrs(field, index, mod_index) {
  if (field.type == 'number') {
    set_id_and_name_attrs(field, index, mod_index, 'value')
  } else if (field.type == 'text') {
    set_id_and_name_attrs(field, index, mod_index, 'description')
  }
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
  var ability_field_cells = $('table').eq(1).find('tbody tr > td:nth-child(2)')
  var ability_scores_fields = ability_field_cells.children('.form-control')
  // every cell in the row starting from the 3rd
  var mod_cells = '> td:nth-child(1n+3)'

  ability_scores_fields.each(function(abil_index, field) {
    var row = $(this).parents('tr')
    var mod_index = 0

    while ($(row).length && (mod_index == 0 || !row_contains_ability_score(row))) {
      row.find(mod_cells).children('input').each(function(_, field) {
        set_mod_attrs(field, abil_index, mod_index)
      })
      row = row.next()
      mod_index++
    }
  })
}

function remove_modifier(e) {
  e.preventDefault()
  var parent_row = $(this).parents('tr')

  if (row_contains_ability_score(parent_row)) {
    // only delete the cells that contain the modifier fields
    var parent_cell = $(this).parent()
    parent_cell.prev().remove()
    parent_cell.prev().remove()
    parent_cell.remove()
  } else {
    // delete the whole row
    parent_row.remove()
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
