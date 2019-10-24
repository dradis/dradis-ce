document.addEventListener "turbolinks:load", ->

  if $('[data-behavior~=subscription-actions]').length
    subscribed = $('[data-behavior~=subscription-actions]').data('subscribed')
    if subscribed
      $('[data-behavior=unsubscribe]').show()
    else
      $('[data-behavior=subscribe]').show()
