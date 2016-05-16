class IssueTable
  $table: null
  selectedColumns: []

  constructor: ->
    @$table       = $('#issue-table table')
    @$column_menu = $('.dropdown-menu.js-table-columns')

    # -------------------------------------------------------- Load table state
    @loadColumnState()
    @showHideColumns()

    # -------------------------------------------------- Install event handlers
    $('#issue-table').on('click', '.js-taglink', @onTagSelected)

    # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # if the user confirmed the deletion
    $('#issue-table').on('confirm:complete', '#delete-selected', @onDeleteSelected)

    # Handle the showing / hiding of table columns
    @$column_menu.find('a').on 'click', @onColumnPickerClick

  loadColumnState: =>
    # TODO: persist this in browser local storage or a cookie
    @selectedColumns = ['title', 'tags', 'affected']
    that = this

    @$column_menu.find('a').each ->
      $link = $(this)
      if that.selectedColumns.indexOf($link.data('column')) > -1
        $($link.find('input')).prop('checked', true)


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
    @showHideColumns()
    false

  onDeleteSelected: (element, answer) ->
    if answer
      $('.js-tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
        $row = $(this).parent().parent()
        $($row.find('td')[2]).replaceWith("<td class=\"loading\">Deleting...</td>")
        $that = $(this)
        $.ajax $(this).data('url'), {
          method: 'DELETE'
          dataType: 'json'
          success: (data) ->
            # Delete row from the table
            $row.remove()
            # TODO: show placeholder if no issues left

            # Delete link from the sidebar
            $("#issue_#{data.id}").remove()

            if $('input[type=checkbox]:checked').length == 0
              $('.js-issue-actions').css('display', 'none')

          error: (foo,bar,foobar) ->
            $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
        }

    # prevent Rails UJS from doing anything else.
    false

  onTagSelected: (event) ->
    $target = $(event.target)
    event.preventDefault()

    $('.js-tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
      $this = $(this)

      $this.prop('checked', false)
      $row = $this.parent().parent()
      $($row.find('td')[2]).replaceWith("<td class=\"loading\">Loading...</td>")

      url   = $this.data('url')
      data  = { issue: { tag_list: $target.data('tag') } }
      $that = $this

      $.ajax url, {
        method: 'PUT',
        data: data,
        dataType: 'json',
        success: (data) ->
          issue_id = $that.val()

          $($row.find('td')[2]).replaceWith(data.tag_cell)
          $("#issues #issue_#{issue_id}").replaceWith(data.issue_link)
          if $('input[type=checkbox]:checked').length == 0
            $('.js-issue-actions').css('display', 'none')

        error: (foo,bar,foobar) ->
          $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
      }

  showHideColumns: =>
    that = this

    $.each @$table.find('thead th'), (index, th)->
      $th = $(th)

      if (column = $(th).data('column'))
        if that.selectedColumns.indexOf(column) > -1
          that.$table.find("td:nth-child(#{index + 1})").css('display', 'table-cell')
          $th.css('display', 'table-cell')
        else
          that.$table.find("td:nth-child(#{index + 1})").css('display', 'none')
          $th.css('display', 'none')

jQuery ->
  if $('body.issues.index').length

    # Checkbox behavior: select all, show 'btn-group', etc.
    $('#select-all').click ->
      $('input[type=checkbox]').not(this).prop('checked', $(this).prop('checked'))


    $('input[type=checkbox].js-multicheck').click ->
      _select_all = $(this).prop('checked')

      if _select_all
        $('input[type=checkbox].js-multicheck').each ->
          _select_all = $(this).prop('checked')
          _select_all

      $('#select-all').prop('checked', _select_all)

    $('input[type=checkbox]').click ->
      if $('input[type=checkbox]:checked.js-multicheck').length
        $('.js-issue-actions').css('display', 'inline-block')
      else
        $('.js-issue-actions').css('display', 'none')


    $('#js-table-filter').on 'keyup', ->
        rex = new RegExp($(this).val(), 'i')
        $('tbody tr').hide();
        $('tbody tr').filter( ->
          rex.test($(this).text());
        ).show();

    new IssueTable
