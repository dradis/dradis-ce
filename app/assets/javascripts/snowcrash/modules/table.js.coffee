class IndexTable
  $table: null
  project: null
  selectedColumns: []
  selectedItemsSelector: ''
  tagColumnIndex: null

  constructor: (@itemName) ->
    @$table       = $('#index-table table')
    @$column_menu = $('.dropdown-menu.js-table-columns')

    @selectedItemsSelector = 'input[type=checkbox]:checked.js-multicheck:visible'

    # -------------------------------------------------------- Load table state
    @loadColumnState()
    @showHideColumns()

    # -------------------------------------------------- Install event handlers
    $('#index-table').on('click', '.js-taglink', @onTagSelected)

    # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # if the user confirmed the deletion
    $('#index-table').on('confirm:complete', '#delete-selected', @onDeleteSelected)

    # Handle the showing / hiding of table columns
    @$column_menu.find('a').on 'click', @onColumnPickerClick

    # Checkbox behavior: select all, show 'btn-group', etc.
    $('.js-select-all-items').click (e)->
      $allCheckbox = $(this).find('input[type=checkbox]')
      isChecked = $allCheckbox.prop('checked')
      if e.target != $allCheckbox[0]
        isChecked = !isChecked
        $allCheckbox.prop('checked', isChecked)

      $('input[type=checkbox].js-multicheck:visible').prop('checked', isChecked)

    # when selecting standalone items, check if we must also check 'select all'
    $('input[type=checkbox].js-multicheck').click ->
      _select_all = $(this).prop('checked')

      if _select_all
        $('input[type=checkbox].js-multicheck').each ->
          _select_all = $(this).prop('checked')
          _select_all

      $('.js-select-all-items > input[type=checkbox]').prop('checked', _select_all)

    # when selecting items or 'select all', refresh toolbar buttons
    $('#index-table').on('click', '.js-select-all-items, input[type=checkbox].js-multicheck', @refreshToolbar)

  loadColumnState: =>
    if Storage?
      @selectedColumns = JSON.parse(localStorage.getItem(@storageKey()))
    else
      console.log "The browser doesn't support local storage of settings."

    @selectedColumns ||= ['title', 'tags', 'affected']

    that = this

    @$column_menu.find('a').each ->
      $link = $(this)
      if that.selectedColumns.indexOf($link.data('column')) > -1
        $link.find('input').prop('checked', true)

  resetToolbar: =>
    $('.js-table-actions').css('display', 'none')
    $('#select-all').prop('checked', false)

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
      that = this
      $('.js-items-table').find(@selectedItemsSelector).each ->
        $row = $(this).parent().parent()
        $($row.find('td')[2]).replaceWith("<td class=\"loading\">Deleting...</td>")
        $.ajax $(this).data('url'), {
          method: 'DELETE'
          dataType: 'json'
          success: (data) ->
            # Delete row from the table
            $row.remove()
            # TODO: show placeholder if no items left

            # Delete link from the sidebar
            $("#item_#{data.id}").remove()

            if $(@selectedItemsSelector).length == 0
              that.resetToolbar()

          error: (foo,bar,foobar) ->
            $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
        }

    # prevent Rails UJS from doing anything else.
    false

  onTagSelected: (event) =>
    that = this
    $target = $(event.target)
    event.preventDefault()

    $('.js-items-table').find(@selectedItemsSelector).each ->
      $this = $(this)

      $row = $this.parent().parent()
      $($row.find('td')[that.tagColumnIndex]).replaceWith("<td class=\"loading\">Loading...</td>")

      url   = $this.data('url')
      data  = { "#{@itemName}": { tag_list: $target.data('tag') } }
      $that = $this

      $.ajax url, {
        method: 'PUT',
        data: data,
        dataType: 'json',
        success: (data) ->
          $that.prop('checked', false)
          item_id = $that.val()

          $($row.find('td')[that.tagColumnIndex]).replaceWith(data.tag_cell)
          $("#items #item_#{item_id}").replaceWith(data.item_link)
          if $(@selectedItemsSelector).length == 0
            that.resetToolbar()

        error: (foo,bar,foobar) ->
          $($row.find('td')[that.tagColumnIndex]).replaceWith("<td class='text-error'>Please try again</td>")
      }

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

  refreshToolbar: ->
    checked = $('input[type=checkbox]:checked.js-multicheck:visible').length
    if checked
      $('.js-table-actions').css('display', 'inline-block')
    else
      $('.js-table-actions').css('display', 'none')

jQuery ->
  window.IndexTable = IndexTable
