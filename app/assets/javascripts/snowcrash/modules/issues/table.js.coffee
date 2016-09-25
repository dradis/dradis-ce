class IssueTable
  $table: null
  project: null
  selectedColumns: []
  # We need this for Issues#update in onTagSelected()
  tagColumnIndex: null

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

    # Handle the combine issues button click
    $('#issue-table').on('click', '#combine-selected', @onCombineSelected)

    # Handle type of combination radios
    $('#modal_combine_issues').on('click', 'input[type=radio]', @onCombineTypeChosen)

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

  onTagSelected: (event) =>
    that = this
    $target = $(event.target)
    event.preventDefault()

    $('.js-tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
      $this = $(this)

      $this.prop('checked', false)
      $row = $this.parent().parent()
      $($row.find('td')[that.tagColumnIndex]).replaceWith("<td class=\"loading\">Loading...</td>")

      url   = $this.data('url')
      data  = { issue: { tag_list: $target.data('tag') } }
      $that = $this

      $.ajax url, {
        method: 'PUT',
        data: data,
        dataType: 'json',
        success: (data) ->
          issue_id = $that.val()

          $($row.find('td')[that.tagColumnIndex]).replaceWith(data.tag_cell)
          $("#issues #issue_#{issue_id}").replaceWith(data.issue_link)
          if $('input[type=checkbox]:checked').length == 0
            $('.js-issue-actions').css('display', 'none')

        error: (foo,bar,foobar) ->
          $($row.find('td')[that.tagColumnIndex]).replaceWith("<td class='text-error'>Please try again</td>")
      }

  # get selected issues ids and their titles, and build a form with that info
  # inside the combine issues modal
  onCombineSelected: (event) ->
    $('#modal_combine_issues #issues_to_combine').empty()

    issues_to_combine = []
    $('.js-tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
      $row = $(this).parent().parent()

      id = @.name.split('_')[1]
      name = $($row.find('td')[1]).find('a').html()
      issues_to_combine.push({id: id, name: name})

    for issue in issues_to_combine
      html =  "<div class='radio'><label><input type='radio' name='id' value='#{issue.id}' />#{issue.name}</label></div>"
      html += "<input type='hidden' name='sources[]' value='#{issue.id}' />"
      $('#modal_combine_issues #issues_to_combine').append(html)

    $("#modal_combine_issues").modal()

    # TODO: $($row.find('td')[2]).replaceWith("<td class=\"loading\">Combining...</td>")

  # when the combine modal is visible, depending on which radio is clicked,
  # hide/show the new issue text field
  onCombineTypeChosen: (event) ->
    if @.value == "new"
      $("#modal_combine_issues input[name=id]").attr("checked", false)
      $("#modal_combine_issues .issue_text").show()
    else
      $("#modal_combine_issues input[name=new_issue]").attr("checked", false)
      $("#modal_combine_issues .issue_text").hide()

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
    "project.#{@project}.issue_columns"

jQuery ->
  if $('body.issues.index').length

    # Checkbox behavior: select all, show 'btn-group', etc.
    $('#select-all').click ->
      $('input[type=checkbox].js-multicheck').not(this).prop('checked', $(this).prop('checked'))

    $('.js-select-all-issues').click (e) ->
      $selectAll = $('#select-all')
      return if e.target == $selectAll[0]
      isChecked = !$selectAll.prop('checked')
      $selectAll.prop('checked', isChecked)
      $('input[type=checkbox].js-multicheck').prop('checked', isChecked)

    $('input[type=checkbox].js-multicheck').click ->
      _select_all = $(this).prop('checked')

      if _select_all
        $('input[type=checkbox].js-multicheck').each ->
          _select_all = $(this).prop('checked')
          _select_all

      $('#select-all').prop('checked', _select_all)

    $('#select-all, input[type=checkbox].js-multicheck').click ->
      checked = $('input[type=checkbox]:checked.js-multicheck').length

      if checked
        $('.js-issue-actions').css('display', 'inline-block')
      else
        $('.js-issue-actions').css('display', 'none')

      if checked > 1
        $('#combine-selected').css('display', 'inline-block')
      else
        $('#combine-selected').css('display', 'none')


    $('#js-table-filter').on 'keyup', ->
        rex = new RegExp($(this).val(), 'i')
        $('tbody tr').hide();
        $('tbody tr').filter( ->
          rex.test($(this).text());
        ).show();

    new IssueTable
