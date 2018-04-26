document.addEventListener "turbolinks:load", ->
  if $('body.issues.show').length
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
      fetch(path, {credentials: 'same-origin'}).then (response) ->
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
