App.cable.subscriptions.create 'NotificationsChannel',
  received: (data)->
    alert('asdfdsa')
    console.log(data)
