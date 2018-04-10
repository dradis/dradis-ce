document.addEventListener "turbolinks:load", ->
  if $('body.sync.settings').length

    $('.sync-settings-table td.value').on('blur', 'input', ->
      $(this).removeClass 'editing'
    ).on('change', 'input', ->
      names          = $(this).attr('name').split('_settings_')
      plugin_name    = names[0]
      setting_name   = names[1]
      post_path      = $(this).parents('form').attr('action')
      full_post_path = post_path + '/' + plugin_name

      ajax_opts =
        context: $(this)
        data:
          setting: { key: setting_name, value: $(this).val() }
          _method: 'put'
        dataType: 'json'
        type: 'post'
        complete: ->
          $(this).removeClass 'saving'
        error: (xhr, status, error) ->
          $(this).addClass 'failed'
        success: (data, status, xhr) ->
          $(this).addClass 'saved'
        url: full_post_path

      $(this).addClass('saving')
      $.ajax(ajax_opts)

    ).on 'keydown', 'input', (e) ->
      $(this).addClass('editing').removeClass('saved', 'failed')

