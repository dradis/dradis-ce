document.addEventListener('turbolinks:load', function() {
  if ($('body.issues.index').length) {
    new IssuesTable('[data-behavior~=issues-table]', 'issue');

    $('[data-behavior~=issues-dropdown-toggle]').on('click', function(e){
      e.stopPropagation();
      $('[data-name~=issues]').click();
    });
  }
});
