document.addEventListener('turbolinks:load', function() {
  if ($('body.issues.index').length) {
    $('[data-behavior~=issues-dropdown-toggle]').on('click', function(e){
      e.stopPropagation();
      $('[data-name~=issues]').click();
    });
  }
});
