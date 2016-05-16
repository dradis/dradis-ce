class IssueTable
  constructor: ->
    $('#issue-table').on('click', '.js-taglink', @tagSelected)
    # We're hooking into Rails UJS data-confirm behavior to only fire the Ajax
    # if the user confirmed the deletion
    $('#issue-table').on('confirm:complete', '#delete-selected', @deleteSelected)

  deleteSelected: (element, answer) ->
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
              $('.js-issue-actions').css('visibility', 'hidden')

          error: (foo,bar,foobar) ->
            $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
        }

    # prevent Rails UJS from doing anything else.
    false

  tagSelected: (event) ->
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
            $('.js-issue-actions').css('visibility', 'hidden')

        error: (foo,bar,foobar) ->
          $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
      }

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
      if $('input[type=checkbox]:checked').length
        $('.js-issue-actions').css('visibility', 'visible')
      else
        $('.js-issue-actions').css('visibility', 'hidden')

    new IssueTable
