document.addEventListener "turbolinks:load", ->
  if $('body.evidence.new').length
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

    $('[data-behavior~=add-evidence-container]').on 'keyup', '#evidence_node', ->
      rule = new RegExp($(this).val(), 'i')
      $('[data-behavior~=existing-node-wrapper]').hide();
      $('[data-behavior~=existing-node-wrapper]').filter ->
        rule.test($(this).find($('[data-behavior~=existing-node-label]')).text())
      .show()

  if $('body.issues.show').length
    $table = $('[data-behavior~=dradis-datatable]')
    $table.on 'dradis:datatable:bulkDelete', ->
      $('[data-behavior~=evidence-count]').text($table.DataTable().rows().count());
