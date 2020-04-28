// This module restores the hidden tag input and ensure the selected tag
// is shown correctly in in issues#form
document.addEventListener('turbolinks:load', function(){
  $form = $('#issues_editor .js-taglink').parents('form[data-behavior~=local-auto-save]')
  if ($form.length) {
    var key = $form.data('autoSaveKey');
    var data = JSON.parse(localStorage.getItem(key));

    if (data != null && data['issue[tag_list]'].length) {
      var $target = $(`#issues_editor .js-taglink[data-tag='${data['issue[tag_list]']}']`)

      if ($target.length) {
        $('#issue_tag_list').val(data["issue[tag_list]"])
        $span = $('#issues_editor .dropdown-toggle span.tag')
        $span.html($target.html())
        $span.css("color", $target.css("color"))
      }
    }
  }
})
