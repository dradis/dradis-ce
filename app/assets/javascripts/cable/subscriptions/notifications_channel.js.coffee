App.cable.subscriptions.create 'NotificationsChannel',
  connected: ->
    console.log('Subscribed to NotificationsChannel.')
    @perform('check_unread', {})
    $(document).on 'turbolinks:load.notifications', =>
      @perform('check_unread', {})

  rejected: ->
    console.log('Error subscribing to NotificationsChannel.')
    $(document).off('.notifications')

  received: (data)->
    $('[data-behavior~=notifications-dot]').removeClass('hidden')
