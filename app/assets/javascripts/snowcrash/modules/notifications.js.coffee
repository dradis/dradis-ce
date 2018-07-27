document.addEventListener 'turbolinks:load', ->
  $dropdown = $('[data-behavior~=notifications-dropdown]')

  App.notificationsChannel.perform('check_unread', {})

  if $dropdown.length
    $container = $('[data-behavior~=notifications-dropdown] + div')

    $dropdown.on 'ajax:beforeSend', (event)->
      if !$container.is(':visible')
        $container.html('<div class="loader"></div>')
      else
        # Don't send out ajax when hiding the dropdown
        return false
