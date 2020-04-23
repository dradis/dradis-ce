document.addEventListener "turbolinks:load", ->
  $('#issues_editor .js-taglink').click (e) ->
    $target = $(e.target)
    $('#issue_tag_list').val($target.data('tag'))
    $span = $("#issues_editor .dropdown-toggle span.tag")
    $span.html($target.html())
    $span.css("color", $target.css("color"))

    $form = $target.parents('form[data-behavior~=local-auto-save]')
    if $form
      console.log($form)
      $('#issue_tag_list').trigger('change')
