document.addEventListener "turbolinks:load", ->
  if $('body.nodes.show').length

    indexTable = new IndexTable('note')
    
    # # Checkbox behavior: select all, show 'btn-group', etc.
    # $('.js-select-all-notes').click (e)->
    #   $allCheckbox = $(this).find('input[type=checkbox]')
    #   isChecked = $allCheckbox.prop('checked')
    #   # Makes the surrounding span also react to this click
    #   if e.target != $allCheckbox[0]
    #     isChecked = !isChecked
    #     $allCheckbox.prop('checked', isChecked)
    #
    #   $('input[type=checkbox].js-multicheck:visible').prop('checked', isChecked)
    #
    # # when selecting standalone issues, check if we must also check 'select all'
    # $('input[type=checkbox].js-multicheck').click ->
    #   _select_all = $(this).prop('checked')
    #
    #   if _select_all
    #     $('input[type=checkbox].js-multicheck').each ->
    #       _select_all = $(this).prop('checked')
    #       _select_all
    #
    #   $('.js-select-all-notes > input[type=checkbox]').prop('checked', _select_all)
    #
    # refreshToolbar = ->
    #   checked = $('input[type=checkbox]:checked.js-multicheck:visible').length
    #   if checked
    #     $('.js-note-actions').css('display', 'inline-block')
    #   else
    #     $('.js-note-actions').css('display', 'none')
    #
    # # on page load refresh toolbar
    # refreshToolbar()
    #
    # # when selecting issues or 'select all', refresh toolbar buttons
    # $('.js-select-all-notes, input[type=checkbox].js-multicheck').click ->
    #   refreshToolbar()
    #
    # selectedIssuesSelector = 'input[type=checkbox]:checked.js-multicheck:visible'
    #
    # # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # # if the user confirmed the deletion
    # $('#notes-table').on('confirm:complete', '#delete-selected', ->
    #
    #   $("#multi-destroy input[name='ids[]']").remove()
    #
    #   $(selectedIssuesSelector).each ->
    #     $("#multi-destroy").append(
    #       "<input type='hidden' name='ids[]' value='#{$(this).data('id')}' />"
    #     )
    #
    #   $('#multi-destroy').submit()
    #
    #   false
    # )
