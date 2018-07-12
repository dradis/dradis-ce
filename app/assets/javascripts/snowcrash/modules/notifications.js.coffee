document.addEventListener 'turbolinks:load', ->
  if $('.js-notifications-dropdown').length
    $container = $('.js-notification-container')
    $count     = $('.js-notification-count')
    $body      = $container.find('.js-notifications-body')
    $footer    = $container.next('.js-footer')
    $loading   = $container.find('.js-loading')

    $('.js-notifications-dropdown').on 'ajax:beforeSend', (event)->
      if !$container.is(':visible')
        $body.html('')
        $count.html('')

        $footer.hide()
        $loading.show()
      else
        # Don't send out ajax when hiding the dropdown
        return false

    $('.js-notifications-dropdown').on 'ajax:complete', (event)->
      $loading.hide()
