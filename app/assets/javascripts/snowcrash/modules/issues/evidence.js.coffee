jQuery ->
  if $('#evidence-tabs').length
    $('#evidence-tabs li').first().addClass('active')
    $('#evidence-tabs .tab-pane').first().addClass('active')

    $('#evidence-tabs a[data-toggle="tab"]').on 'shown', (ev)->
      tabContentHeight = $('#evidence-tabs .tab-content').css('height')
      $tabs            = $('#evidence-tabs #evidence-host-list')
      if $tabs.height() < tabContentHeight
        $tabs.css('height', tabContentHeight)
      else
        $tabs.css('height', null)
