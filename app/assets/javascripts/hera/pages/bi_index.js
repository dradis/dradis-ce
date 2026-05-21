document.addEventListener('turbo:load', function () {
  if ($('body.static_pages.bi_index').length) {
    $('[data-behavior~=widget-filter]').on('change', function (e) {
      e.target.closest('form').requestSubmit();
    });
  }
});
