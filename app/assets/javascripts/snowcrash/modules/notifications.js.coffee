document.addEventListener 'turbolinks:load', ->
  $dropdown = $('[data-id="js-notifications-dropdown"]')

  if $dropdown.length
    $container = $('[data-id="js-notification-container"]')

    $dropdown.on 'ajax:beforeSend', (event)->
      if !$container.is(':visible')
        $container.html('<div class="loader"></div>')
      else
        # Don't send out ajax when hiding the dropdown
        return false
