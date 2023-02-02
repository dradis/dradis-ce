document.addEventListener "turbolinks:load", ->
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

  $('[data-behavior="send"]').on 'click', ->
      template = $("input[type='radio'][name='template']:checked").val()
      payload = {name: 'report.exported', properties: {exporter: template}}
      $.ajax
        url: '/setup/analytics/create',
        method: 'get',
        data: payload
