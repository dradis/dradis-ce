App.notificationsChannel = App.cable.subscriptions.create 'NotificationsChannel',
  connected: ->
    console.log('Subscribed to NotificationsChannel.')

  rejected: ->
    console.log('Error subscribing to NotificationsChannel.')

  received: (data)->
    $('[data-behavior~=notifications-dot]').removeClass('hidden')
