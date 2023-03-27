document.addEventListener('turbolinks:load', function () {
  if ($('[data-behavior~=qa-viewer]').length) {
    $('[data-qa-visible]').each(function () {
      if ($(this).data('qa-visible') === true) {
        $(this).removeClass('d-none');
        $(this).prev().addClass('d-none');
      } else {
        $(this).addClass('d-none');
      }
    });
  }
});
