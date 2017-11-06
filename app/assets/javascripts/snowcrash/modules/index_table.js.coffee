class IndexTable
  project: null
  selectedColumns: []
  selectedItemsSelector: ''
  tagColumnIndex: null

  constructor: (@itemName) ->
    @$jsTable     = $('.js-index-table')
    @$table       = $('.js-index-table table')
    @$columnMenu  = $('.dropdown-menu.js-table-columns')

    @checkboxSelector       = 'input[type=checkbox].js-multicheck'
    @selectedItemsSelector  = "#{@checkboxSelector}:checked:visible"

    # -------------------------------------------------------- Load table state
    @loadColumnState()
    @showHideColumns()

    # -------------------------------------------------- Install event handlers
    # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # if the user confirmed the deletion
    @$jsTable.on('confirm:complete', '#delete-selected', @onDeleteSelected)

    # Handle the showing / hiding of table columns
    @$columnMenu.find('a').on 'click', @onColumnPickerClick

    # Checkbox behavior: select all, show 'btn-group', etc.
    $('.js-index-table-select-all').click (e)=>
      $allCheckbox = $(this).find('input[type=checkbox]')
      isChecked = $allCheckbox.prop('checked')
      if e.target != $allCheckbox[0]
        isChecked = !isChecked
        $allCheckbox.prop('checked', isChecked)

      $("#{@checkboxSelector}:visible").prop('checked', isChecked)

    # when selecting standalone items, check if we must also check 'select all'
    $(@checkboxSelector).click ->
      _select_all = $(this).prop('checked')

      if _select_all
        $(@checkboxSelector).each ->
          _select_all = $(this).prop('checked')
          _select_all

      $('.js-index-table-select-all > input[type=checkbox]').prop('checked', _select_all)

    # when selecting items or 'select all', refresh toolbar buttons
    @$jsTable.on('click', ".js-index-table-select-all, #{@checkboxSelector}", @refreshToolbar)

  loadColumnState: =>
    if Storage?
      @selectedColumns = JSON.parse(localStorage.getItem(@storageKey()))
    else
      console.log "The browser doesn't support local storage of settings."

    @selectedColumns ||= ['title', 'created', 'updated']

    that = this

    @$columnMenu.find('a').each ->
      $link = $(this)
      if that.selectedColumns.indexOf($link.data('column')) > -1
        $link.find('input').prop('checked', true)

  resetToolbar: =>
    $('.js-index-table-actions').css('display', 'none')
    $('.js-index-select-all #select-all').prop('checked', false)

  onColumnPickerClick: (event) =>
    $target = $(event.currentTarget)
    val     = $target.data('column')
    $input  = $target.find('input')

    if ((idx = @selectedColumns.indexOf(val)) > -1)
      @selectedColumns.splice(idx, 1)
      setTimeout ->
        $input.prop('checked', false)
      , 0
    else
      @selectedColumns.push(val)
      setTimeout ->
        $input.prop('checked', true)
      , 0

    $(event.target).blur()
    @saveColumnState()
    @showHideColumns()
    false

  onDeleteSelected: (element, answer) =>
    if answer
      that   = this
      ids = []

      $('.js-items-table').find(@selectedItemsSelector).each ->
        $row = $(this).parent().parent()
        $($row.find('td')[2]).replaceWith("<td class=\"loading\">Deleting...</td>")
        ids.push($(this).val())

      $.ajax @$jsTable.data('destroy-url'), {
        method: 'DELETE'
        dataType: 'json'
        data: {ids: ids}
        success: (data) ->
          for id in ids
            $("#checkbox_#{that.itemName}_#{id}").closest('tr').remove()
            $("##{that.itemName}_#{id}").remove()

          if $(that.selectedItemsSelector).length == 0
            that.resetToolbar()

          $('#modal-console').modal()
          ConsoleUpdater.jobId = data.jobId
          $('#console').empty()
          $('#result').data('id', ConsoleUpdater.jobId)
          $('#result').show()

          ConsoleUpdater.parsing = true;
          setTimeout(ConsoleUpdater.updateConsole, 200);

          # TODO: show placeholder if no items left

        error: ->
          for id in ids
            $row = $("#checkbox_#{that.itemName}_#{id}").closest('tr')
            $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
      }

    # prevent Rails UJS from doing anything else.
    false

  saveColumnState: ->
    if Storage?
      localStorage.setItem(@storageKey(), JSON.stringify(@selectedColumns))
    else
      console.log "The browser doesn't support local storage of settings."
      console.log "Column selection can't be saved."

  showHideColumns: =>
    that = this

    $.each @$table.find('thead th'), (index, th)->
      $th = $(th)

      if (column = $(th).data('column'))
        that.tagColumnIndex ||= index if column == 'tags'
        if that.selectedColumns.indexOf(column) > -1
          that.$table.find("td:nth-child(#{index + 1})").css('display', 'table-cell')
          $th.css('display', 'table-cell')
        else
          that.$table.find("td:nth-child(#{index + 1})").css('display', 'none')
          $th.css('display', 'none')

  storageKey: ->
    @project ||= $('.brand').data('project')
    "project.#{@project}.#{@itemName}_columns"

  refreshToolbar: =>
    checked = $(@selectedItemsSelector).length
    if checked
      $('.js-index-table-actions').css('display', 'inline-block')
    else
      $('.js-index-table-actions').css('display', 'none')

window.IndexTable = IndexTable
