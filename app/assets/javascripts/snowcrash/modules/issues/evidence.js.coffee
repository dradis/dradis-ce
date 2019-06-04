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

  $(".js-issues-evidence-select-all, .js-multicheck").change =>
    checked = $(".js-multicheck:checked:visible").length
    if checked
      $(".js-issues-evidence-actions").css('display', 'inline-block')
    else
      $(".js-issues-evidence-actions").css('display', 'none')

  $('#issues-evidence-select-all').change =>
    if $('#issues-evidence-select-all').prop('checked')
      checker(true)
    else
      checker(false)

  $(".js-multicheck").change =>
    return unless $('#issues-evidence-select-all').prop('checked') && !this.checked

    $('#issues-evidence-select-all').prop('checked', false)

  $('[data-toggle="tab"]').click =>
    $(".js-issues-evidence-actions").css('display', 'none')
    $('#issues-evidence-select-all').prop('checked', false)
    checker(false)

  $('.js-issues-evidence-delete').on 'confirm:complete', (element, answer) ->
    return unless answer

    ids = []

    $('.evidence-content.active .js-multicheck:checked:visible').each ->
      ids.push($(this).val())

    $.ajax $('#evidence-host-list li.active a').data('destroy-url'), {
      method: 'DELETE'
      dataType: 'json'
      data: { ids: ids, custom_controller: 'evidence', notice: 'Evidence deleted for selected nodes.' }
      success: (data) ->
        window.location.replace($('#evidence-host-list li.active a').data('redirect-to'))
    }

  checker = (checked_value) ->
    $('.js-multicheck').each (index, element) ->
      jqueried_element = $('#' + element['id'])
      jqueried_element.prop('checked', checked_value)
