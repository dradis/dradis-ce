document.addEventListener "turbolinks:load", ->
  console.log('asdf')
  App.cable.subscriptions.create { channel: 'NotificationChannel' },
    received: (data)->
      alert('asdfdsa')
      console.log(data)
