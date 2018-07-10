document.addEventListener 'turbolinks:load', ->
  if $('.js-notifications-dropdown').length > 0
    $container = $('.js-notification-container')
    $.ajax $container.data('url'),
      dataType: 'json',
      data: {count: 7},
      beforeSend: () ->
        $('.no-content.loading').remove()

      success: (data) ->
        # console.log(data)
        if data.length == 0
          $container.append(
            $('<div>', class: 'no-content text-center').
              html('You currently have no notifications.')
          )
        else
          $('.js-notification-count').html("Notifications (#{data.count})")

          for notification in data.notifications
            unread_class = if notification.unread then 'unread' else ''
            $container.append($('<li>', class: "notification #{unread_class}"))
            $('li.notification:last').append($('<div>', class: 'body'))

            $body = $('li.notification:last > .body')
            $body.append($('<div>', class: 'time').html(notification.created_at_ago))
            $body.append($('<div>', class: 'title').html(notification.render_title))
            $body.append($('<div>', class: 'details').html(notification.avatar))
