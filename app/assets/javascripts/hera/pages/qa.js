document.addEventListener('turbo:load', () => {
  if ($('[data-behavior~=qa-viewer]').length) {
    $('[data-qa-visible]').each(function () {
      $(this).toggleClass('d-none', $(this).data('qa-visible') === false);
    });
  }

  // Initialize inline comment threads on any QA show page with a container
  const container = document.querySelector('[data-behavior~=inline-threads-container]');
  if (container) {
    new InlineThreadTurbo(container);
  }
});
