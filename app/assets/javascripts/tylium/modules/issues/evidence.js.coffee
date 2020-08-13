document.addEventListener "turbolinks:load", ->
  if $('body.issues.show').length
    $('[data-behavior~=evidence-link]').first().addClass('active')
    $('[data-behavior~=evidence-tab-pane]').first().addClass('active show')

    $('#evidence-host-list a[data-toggle~=pill]').on 'click', (ev)->
      path   = $(this).data('path')
      node   = $(this).data('node')
      fetch(path, {credentials: 'include'}).then (response) ->
        if response.redirected
          window.location.href = '/'
        else
          response.text()
          .then (html) ->
            $("##{node}").html(html)

    $('.js-add-evidence').click ->
      $('#js-add-evidence-container').slideToggle()

    $('#js-add-evidence-container').on 'change', '#evidence_content', ->
      $('#template-content').text($(this).val())

    $('#js-add-evidence-container').on 'keyup', '#evidence_node', ->
      rule = new RegExp($(this).val(), 'i')
      $('[data-behavior~=existing-node-wrapper]').hide();
      $('[data-behavior~=existing-node-wrapper]').filter ->
        rule.test($(this).find($('[data-behavior~=existing-node-label]')).text())
      .show()
