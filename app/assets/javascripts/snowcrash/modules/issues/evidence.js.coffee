jQuery ->
  if $('#evidence-tabs').length
    $('#evidence-tabs li').first().addClass('active')
    $('#evidence-tabs .tab-pane').first().addClass('active')

    $('#evidence-tabs a[data-toggle="tab"]').on 'shown', (ev)->
      $('#evidence-tabs #evidence-host-list').css('height', $('#evidence-tabs .tab-content').css('height'))
