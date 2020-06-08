# To initialize:
#
#   new ItemsTable('#table-id', 'item_name')
#
# Where:
#   - '#table-id' is the ID of a <div> which wraps the <table> AND the toolbar
#     (so not the ID of the <table> itself). NB the actual <table> must have
#     the class '.items-table'
#
#   - 'item_name' is the name of your model, e.g. 'issue', 'node'
class @ItemsTable
  project: null
  sortData: {}
  selectedColumns: []
  selectedItemsSelector: ''
  columnIndices: {}

  constructor: (@tableId, @itemName, @defaultColumns = ['title', 'created', 'updated']) ->
    @$jsTable     = $(@tableId)
    @$table       = @$jsTable.find('.items-table')
    @$columnMenu  = $("#{@tableId} .dropdown-menu.js-table-columns")

    @checkboxSelector       = "#{@tableId} input[type=checkbox].js-multicheck"
    @selectedItemsSelector  = "#{@checkboxSelector}:checked:visible"
    that = this

    # -------------------------------------------------------- Load table state
    @loadColumnState()
    @showHideColumns()

    @loadSortState()

    # -------------------------------------------------- Install event handlers
    # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # if the user confirmed the deletion
    @$jsTable.on('confirm:complete', '.js-items-table-delete', @onDeleteSelected)

    # Handle the showing / hiding of table columns
    @$columnMenu.find('a').on 'click', @onColumnPickerClick

    # Checkbox behavior: select all, show 'btn-group', etc.
    $("#{@tableId} .js-items-table-select-all").click (e) ->
      $allCheckbox = $(this).find('input[type=checkbox]')
      isChecked = $allCheckbox.prop('checked')
      if e.target != $allCheckbox[0]
        isChecked = !isChecked
        $allCheckbox.prop('checked', isChecked)

      $("#{that.checkboxSelector}:visible").prop('checked', isChecked)

    # when selecting standalone items, check if we must also check 'select all'
    $(@checkboxSelector).click ->
      _select_all = $(this).prop('checked')

      if _select_all
        $(that.checkboxSelector).each ->
          _select_all = $(this).prop('checked')
          _select_all

      $("#{that.tableId} .js-items-table-select-all > input[type=checkbox]").prop('checked', _select_all)

    # when selecting items or 'select all', refresh toolbar buttons
    $("#{@tableId} .js-items-table-select-all, #{@checkboxSelector}").click =>
      @refreshToolbar()

    # Table filtering
    $("#{@tableId} .js-table-filter").on 'keyup', ->
      rex = new RegExp($(this).val(), 'i')
      $("#{that.tableId} tbody tr").hide()
      $("#{that.tableId} tbody tr").filter( ->
        rex.test($(this).text())
      ).show()

    # Table sorting
    @$table.stupidtable()
    @$table.find('th').eq(@sortData.column).stupidsort(@sortData.direction)
    @$table.on 'aftertablesort', @onAfterTableSort

    @afterInitialize()

  # Classes that inherit from this may add extra hooks here
  afterInitialize: ->

  loadColumnState: =>
    if Storage?
      @selectedColumns = JSON.parse(localStorage.getItem(@storageKey()))
    else
      console.log "The browser doesn't support local storage of settings."

    @selectedColumns ||= @defaultColumns

    that = this

    @$columnMenu.find('a').each ->
      $link = $(this)
      if that.selectedColumns.indexOf($link.data('column')) > -1
        $link.find('input').prop('checked', true)

  loadSortState: =>
    if Storage?
      @sortData = JSON.parse(localStorage.getItem("#{@storageKey()}-sort-state"))
    else
      console.log "The browser doesn't support local storage of settings."

    @sortData ||= { column: 1, direction: 'asc' }

  resetToolbar: =>
    $("#{@tableId} .js-items-table-actions").css('display', 'none')
    $("#{@tableId} .js-items-select-all #select-all").prop('checked', false)

  onAfterTableSort: (event, data) =>
    @sortData.column    = data.column
    @sortData.direction = data.direction
    @saveSortState()

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

      $(@selectedItemsSelector).each ->
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
            $("##{that.itemName}_#{id}_link").remove()

          if $(that.selectedItemsSelector).length == 0
            that.resetToolbar()

          if data.success
            if data.jobId?
              # background deletion
              that.showConsole(data.jobId)
            else
              # inline deletion
              that.showAlert(data.msg, 'success')
          else
            that.showAlert(data.msg, 'error')

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

  saveSortState: ->
    if Storage?
      localStorage.setItem("#{@storageKey()}-sort-state", JSON.stringify( @sortData ))
    else
      console.log "The browser doesn't support local storage of settings."
      console.log "Column sorting can't be saved."

  showHideColumns: =>
    that = this

    $.each @$table.find('thead th'), (index, th)->
      $th = $(th)

      if (column = $(th).data('column'))
        that.columnIndices[column] = index
        if that.selectedColumns.indexOf(column) > -1
          that.$table.find("td:nth-child(#{index + 1}):first").css('display', 'table-cell')
          $th.css('display', 'table-cell')
        else
          that.$table.find("td:nth-child(#{index + 1}):first").css('display', 'none')
          $th.css('display', 'none')

  showAlert: (msg, klass) =>
    $('.secondary-sidebar-content').prepend(
      "<div class='alert alert-#{klass}'>
        <a class='close' data-dismiss='alert' href='javascript:void(0)'>x</a>
        #{msg}
      </div>"
    )

  showConsole: (jobId) =>
    # the table may set the url to redirect to when closing the console
    close_url = @$jsTable.data('close-console-url')
    $('#result').data('close-url', close_url) if close_url

    # show console
    $('#modal-console').modal('show')
    ConsoleUpdater.jobId = jobId
    $('#console').empty()
    $('#result').data('id', ConsoleUpdater.jobId)
    $('#result').show()

    # start console
    ConsoleUpdater.parsing = true;
    setTimeout(ConsoleUpdater.updateConsole, 1000);

  storageKey: ->
    @$jsTable.data('storage-key')

  refreshToolbar: =>
    checked = $(@selectedItemsSelector).length
    if checked
      $("#{@tableId} .js-items-table-actions").css('display', 'inline-block')
    else
      $("#{@tableId} .js-items-table-actions").css('display', 'none')
