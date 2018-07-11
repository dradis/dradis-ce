document.addEventListener 'turbolinks:load', ->
  if $('.js-notifications-dropdown').length
    $container = $('.js-notification-container')
    $empty     = $container.find('.js-no-content')
    $footer    = $container.next('.js-footer')
    $loading   = $container.find('.js-loading')

    $('.js-notifications-dropdown').click ->
      unless $container.is(':visible')
        $.ajax $container.data('url'),
          dataType: 'json',
          data: {count: 7},
          beforeSend: () ->
            $container.find('li.notification').remove()

            $empty.hide()
            $footer.hide()
            $loading.show()

          success: (data) ->
            $('.js-notification-count').html("Notifications (#{data.count})")

            if data.count == 0
              $empty.show()
            else
              for notification in data.notifications
                unread_class = if notification.unread then 'unread' else ''
                $container.append($('<li>', class: "notification #{unread_class}"))
                $('li.notification:last').append($('<div>', class: 'body'))

                $body = $('li.notification:last > .body')
                $body.append($('<div>', class: 'time').html(notification.created_at_ago))
                $body.append($('<div>', class: 'title').html(notification.render_title))
                $body.append($('<div>', class: 'details').html(notification.avatar))

              $footer.show()

          complete: () ->
            $loading.hide()
