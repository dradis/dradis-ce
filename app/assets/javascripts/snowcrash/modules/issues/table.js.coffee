class IssueTable
  constructor: ->
    $('#issue-table').on('click', '.js-taglink', @tagSelected)
    # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # if the user confirmed the deletion
    $('#issue-table').on('confirm:complete', '#delete-selected', @deleteSelected)

  deleteSelected: (element, answer) ->
    if answer
      $('#tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
        $row = $(this).parent().parent()
        $($row.find('td')[2]).replaceWith("<td class=\"loading\">Deleting...</td>")
        $that = $(this)
        $.ajax $(this).data('url'), {
          type: 'DELETE'
          dataType: 'json'
          success: (data) ->
            # Delete row from the table
            $row.remove()
            # TODO: show placeholder if no issues left

            # Delete link from the sidebar
            $("#issue_#{data.id}").remove()

          error: (foo,bar,foobar) ->
            $($row.find('td')[2]).replaceWith("<td class='error'>Please try again</td>")
        }

    # prevent Rails UJS from doing anything else.
    false

  tagSelected: (event) ->
    $target = $(event.target)
    event.preventDefault()

    $('#tbl-issues').find('input[type=checkbox]:checked.js-multicheck').each ->
      $(this).prop('checked', false)
      $row = $(this).parent().parent()
      $($row.find('td')[2]).replaceWith("<td class=\"loading\">Loading...</td>")
      $.ajax $(this).data('url'), {
        type: 'PUT',
        data: {issue: {tag_list: $target.data('tag')}},
        dataType: 'json',
        success: (data) ->
          issue_id = $($row.find('td')[0]).find('input').attr('id')

          $($row.find('td')[2]).replaceWith(data.tag_cell)
          $("#issues ##{issue_id}").replaceWith(data.issue_link)
      }

jQuery ->
  if ($('#issues').length > 0)

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
      if $('input[type=checkbox]:checked').length
        $('.btn-group').css('visibility', 'visible')
      else
        $('.btn-group').css('visibility', 'hidden')

    new IssueTable