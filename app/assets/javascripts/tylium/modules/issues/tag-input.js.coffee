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
