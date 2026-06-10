document.addEventListener('turbo:load', function () {
  if ($('body.static_pages.bi_index').length) {
    $('[data-behavior~=widget-filter]').on('change', function (e) {
      const form = e.target.closest('form');
      const frameId = form.dataset.turboFrame;
      if (frameId) {
        $(`#${frameId} [data-behavior~=fetch-loader]`).removeClass('d-none');
        $(`#${frameId} [data-behavior~=widget-content]`).addClass('d-none');
      }
      form.requestSubmit();
    });
  }
});
