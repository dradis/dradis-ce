document.addEventListener('turbolinks:load', function () {
  if ($('body.issues.index').length) {
    $('[data-behavior~=import-dropdown-toggle]').on('click', function (e) {
      e.stopPropagation();
      $(
        '[data-behavior~=import-box-header] [data-behavior~=toggle-chevron]'
      ).toggleClass('fa-chevron-down fa-chevron-up');
      $('[data-behavior~=import-box]').toggle();
    });
  }
});
