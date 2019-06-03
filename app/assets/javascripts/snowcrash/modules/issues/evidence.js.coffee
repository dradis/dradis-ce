document.addEventListener "turbolinks:load", ->
  return unless $('body.issues.show').length

  $('#evidence-tabs li').first().addClass('active')
  $('#evidence-tabs .tab-pane').first().addClass('active')

  $('i[data-toggle="tooltip"]').tooltip()

  $('#evidence-host-list a[data-toggle="tab"]').on 'shown', (ev)->
    tabContentHeight = $('#evidence-tabs .tab-content').height()
    $tabs            = $('#evidence-tabs #evidence-host-list')

    # This enlarges the tab's height. Later if the tab content is shorter
    # the tabs would be a bit taller than necessary, but thats a better
    # visual effect than the other way around (short tabs w/ tall content)
    if $tabs.height() < tabContentHeight
      $tabs.css('height', tabContentHeight)

    path   = $(this).data('path')
    node   = $(this).data('node')
    fetch(path, {credentials: 'include'}).then (response) ->
      if response.redirected
        window.location.href = '/'
      else
        response.text()
        .then (html) ->
          $("##{node}").html(html)

  $('.js-add-evidence').click ->
    $('#js-add-evidence-container').slideToggle()

  $('#js-add-evidence-container').on 'change', '#evidence_content', ->
    # $('#evidence_content').val($(this).val())
    $('#template-content').text($(this).val())

  $('#js-add-evidence-container').on 'keyup', '#evidence_node', ->
    rule = new RegExp($(this).val(), 'i')
    $('#existing-node-list label').hide();
    $('#existing-node-list label').filter ->
      rule.test($(this).text())
    .show()



  # when selecting items or 'select all', refresh toolbar buttons
  $(".js-items-table-select-all, input[type=checkbox].js-multicheck").change =>
    # @refreshToolbar()
    checked = $("input[type=checkbox].js-multicheck:checked:visible").length
    if checked
      $(".js-items-table-actions").css('display', 'inline-block')
    else
      $(".js-items-table-actions").css('display', 'none')

  checker = (checked_value) ->
    $('input[type=checkbox].js-multicheck').each (index, element) ->
        jqueried_element = $('#' + element['id'])
        jqueried_element.prop('checked', checked_value)

  $('#issues-evidence-select-all').change =>
    if $('#issues-evidence-select-all').prop('checked')
      checker(true)
    else
      checker(false)
      $(".js-items-table-actions").css('display', 'none')

  $('[data-toggle="tab"]').click =>
    $(".js-items-table-actions").css('display', 'none')
    $('#issues-evidence-select-all').prop('checked', false)
    checker(false)

  $('.js-items-table-delete').on 'confirm:complete', (element, answer) ->
    if answer
      that = this
      ids = []

      $('.evidence-content.active input[type=checkbox]:checked:visible').each ->
        # $row = $(this).parent().parent()
        # $($row.find('td')[2]).replaceWith("<td class=\"loading\">Deleting...</td>")

        # $('#evidence-host-list li.active a').data('node-id')
        ids.push($(this).val())

      $.ajax $('#evidence-host-list li.active a').data('destroy-url'), {
        method: 'DELETE'
        dataType: 'json'
        data: { ids: ids, custom_controller: 'evidence', notice: 'Evidence deleted for selected nodes.' }
        success: (data) ->
          window.location.replace($('#evidence-host-list li.active a').data('redirect-to'))

          # for id in ids
          #   $("#checkbox_#{that.itemName}_#{id}").closest('tr').remove()
          #   $("##{that.itemName}_#{id}_link").remove()

          # if $(that.selectedItemsSelector).length == 0
          #   that.resetToolbar()

          # if data.success
          #   if data.jobId?
          #     # background deletion
          #     that.showConsole(data.jobId)
          #   else
          #     # inline deletion
          #     that.showAlert(data.msg, 'success')
          # else
          #   that.showAlert(data.msg, 'error')

          # TODO: show placeholder if no items left

        error: ->
          # for id in ids
          #   $row = $("#checkbox_#{that.itemName}_#{id}").closest('tr')
          #   $($row.find('td')[2]).replaceWith("<td class='text-error'>Please try again</td>")
      }

    # prevent Rails UJS from doing anything else.
    false

  # refreshToolbar: =>
  #   checked = $("input[type=checkbox].js-multicheck:checked:visible").length
  #   if checked
  #     $(".js-items-table-actions").css('display', 'inline-block')
  #   else
  #     $(".js-items-table-actions").css('display', 'none')
