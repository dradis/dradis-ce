document.addEventListener 'turbolinks:load', ->
  $alertDot   = $('[data-id="js-notifications-dot"]')
  $container  = $('[data-id="js-notification-container"]')
  $dropdown   = $('[data-id="js-notifications-dropdown"]')

  if $dropdown.length
    $dropdown.on 'ajax:beforeSend', (event)->
      if !$container.is(':visible')
        $alertDot.hide()
        $container.html('<div class="loader"></div>')
      else
        # Don't send out ajax when hiding the dropdown
        return false
