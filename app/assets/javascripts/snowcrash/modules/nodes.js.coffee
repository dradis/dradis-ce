jQuery ->
  if $('body.nodes.show').length
    $('#scripts-tabs li').first().addClass('active')
    $('#scripts-tabs .tab-pane').first().addClass('active')
