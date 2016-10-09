import $ from "jquery"

// delete the 2 fields above the parent
// and then delete the parent also
function remove_modifier(e) {
  e.preventDefault()
  var parent = $(this).parent()
  parent.prev().remove()
  parent.prev().remove()
  parent.remove()
  renumber_modifiers()
}

function add_modifier(e) {
  e.preventDefault()
  var parent = $('#modifiers')
  parent.append(
    '<div class="form-group">' +
    '<label class="control-label" for="">Value</label>' +
    '<input class="form-control" id="" name="" type="number"></div>'
  )
  parent.append(
    '<div class="form-group">' +
    '<label class="control-label" for="">Description</label>' +
    '<input class="form-control" id="" name="" type="text"></div>'
  )
  parent.append(
    '<div style="text-align: right; clear: both;">' +
    '<a href="#" class="remove-modifier">− Remove</a></div>'
  )
  renumber_modifiers()
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

function run() {
  $(document).on('click', '.remove-modifier', remove_modifier)
  $(document).ready(function() { $('#add-modifier').on('click', add_modifier) })
}

export var Fields = { run: run }
