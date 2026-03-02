document.addEventListener('turbo:load', function () {
  if ($('[data-behavior~=qa-viewer]').length) {
    $('[data-qa-visible]').each(function () {
      $(this).toggleClass('d-none', $(this).data('qa-visible') === false);
    });
  }

  // Initialize inline comment threads on QA issue show page
  if (document.querySelector('body.qa-issues.show')) {
    var container = document.querySelector('[data-behavior~=inline-threads-container]');
    if (container) {
      new InlineThreadManager(container);
    }
  }
});
