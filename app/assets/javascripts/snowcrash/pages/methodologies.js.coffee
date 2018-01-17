# This file controls the behavior of the Methodologies module, every time an
# item is ticked or un-ticked, we persist the change on the server.

document.addEventListener "turbolinks:load", ->
  if $('#methodologies').length
    $('#m-tabs a:first').tab('show')

    $('input:checkbox:checked').parent().addClass('done')

    $('input[type=checkbox]').click ->
      url = $(this).closest('.tab-pane').data('url')
      [section, task] = $(this).attr('name').split('~')
      data = {
        section: section,
        task: task,
        checked: $(this).prop('checked')
      }
      $li = $(this).parent()
      $li.removeClass('failed').addClass('saving')

      $.ajax url, {
        type: 'PUT',
        data: data,
        complete: ->
          $li.removeClass('saving')
        error: (xhr, options, error)->
          $li.addClass('failed')
        success: ->
          $li.addClass('saved')
      }

      if ($(this).prop('checked'))
        $li.addClass('done')
      else
        $li.removeClass('done')

  if $('#methodology_content').length

    timer = 0
    $('#methodology_content').on 'textchange', (event, previousText) ->
      clearTimeout(timer)

      timer = setTimeout ->
        data = { content: $('#methodology_content').val() }
        $.ajax
          type: 'POST',
          url: $("#methodology_content").data('preview'),
          data: data,
          dataType: 'script'

      , 500
