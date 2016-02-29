jQuery ->
  if $('body.export').length

    # Detect Export click
    $('.js-export-button').on 'click', (e)->
      e.preventDefault()

      $form   = $(this).closest('form')
      $action = $form.find('input[name=action]:checked')

      $form.attr('action', $action.val())
      # $action.remove()
      $form.submit()

    # Show the default tab
    $( "#plugin-chooser a[data-target='#plugin-html_export']" ).tab('show')
