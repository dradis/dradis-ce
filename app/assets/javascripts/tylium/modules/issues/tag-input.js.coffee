document.addEventListener "turbolinks:load", ->
  $('#issues_editor .js-taglink').click (e) ->
    $target = $(e.target)
    $('#issue_tag_list').val($target.data('tag'))
    $span = $("#issues_editor .dropdown-toggle span.tag")
    $span.html($target.html())
    $span.css("color", $target.css("color"))

    # Trigger local auto save and store selected tag value in local cache
    $form = $target.parents('form[data-behavior~=local-auto-save]')
    if $form
      $('#issue_tag_list').trigger('textchange')

  # Not really fond of putting this piece of code here, but I'm not sure where else to put it.
  # It finds the stored #issue_tag_list value and display it in the view.
  $form = $('#issues_editor .js-taglink').parents('form[data-behavior~=local-auto-save]')
  if $form
    key = $form.data('autoSaveKey')

    if typeof Storage != "undefined" && Storage != null
      data = JSON.parse(localStorage.getItem(key))
    else
      console.log 'The browser doesn\'t support local storage of settings.'

    if data != null && data['issue[tag_list]'].length
      $target = $("#issues_editor .js-taglink[data-tag='#{data['issue[tag_list]']}']")

      if $target.length
        $('#issue_tag_list').val(data["issue[tag_list]"])
        $span = $('#issues_editor .dropdown-toggle span.tag')
        $span.html($target.html())
        $span.css("color", $target.css("color"))

