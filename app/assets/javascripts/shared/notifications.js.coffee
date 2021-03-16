loadNotificationsDropdown = ->
  $dropdown = $('[data-behavior~=notifications-dropdown]')

  $dropdown.click (e) ->
    if $('[data-behavior~=navbar-collapse]').not('.show').length
      e.preventDefault()

      $.ajax
        url: $dropdown.attr('href') + '.js'
        dataType: 'script'
        method: 'GET'
        beforeSend: (e)->
          $container = $('[data-behavior~=notifications-dropdown] + div')
          if !$container.is(':visible')
            $container.html('<div class="loader"></div>')
          else
            # Don't send out ajax when hiding the dropdown
            return false
    else
      $(this).removeAttr('data-toggle')

if (typeof window.Turbolinks != 'undefined' && window.Turbolinks != null)
  document.addEventListener('turbolinks:load', loadNotificationsDropdown)
else
  $(document).ready(loadNotificationsDropdown)
