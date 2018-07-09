document.addEventListener 'turbolinks:load', ->
  if $('.js-notifications-dropdown')
    $.ajax url,
      dataType: 'json',
      beforeSend: () ->
        $('.no-content.loading').remove()

      success: (data) ->
        $container = $('.js-notification-container')
        if data.length == 0
          $container.append(
            $('<div>', class: 'no-content text-center').
              html('You currently have no notifications.')
          )
        else
          for notification in data
            unread_class = notification.unread ? 'unread' : ''
            $container.append($('<li>', class: "notification #{unread_class}"))
            $('li.notification').append($('<div>', class: 'body'))

            $('.body').append($('<div>', class: 'time').html(notification.created_at_ago)
            $('.body').append($('<div>', class: 'title').html(notification.render_title))
            $('.body').append($('<div>', class: 'details').html(notificatio.avatar))
