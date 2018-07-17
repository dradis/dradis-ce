App.cable.subscriptions.create 'NotificationsChannel',
  received: (data)->
    console.log(data)
    $('[data-id="js-notifications-dot"]').show()
