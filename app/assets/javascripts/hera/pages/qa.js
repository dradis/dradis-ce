document.addEventListener('turbo:load', () => {
  if ($('[data-behavior~=qa-viewer]').length) {
    toggleQaVisibility(document);
  }

  // Initialize inline comment threads on any QA show page with a container
  const container = document.querySelector('[data-behavior~=inline-threads-container]');
  if (container) {
    new InlineThreadTurbo(container);
  }
});

// QA content fetched into the page after turbo:load (e.g. a tab loaded via
// [data-behavior~=fetch]) needs its own qa-visible links toggled, since the
// turbo:load handler above already ran before this content existed.
$(document).on('dradis:fetch', '[data-behavior~=qa-viewer]', (event) => {
  toggleQaVisibility(event.target);
});

function toggleQaVisibility(scope) {
  $(scope)
    .find('[data-qa-visible]')
    .each(function () {
      $(this).toggleClass('d-none', $(this).data('qa-visible') === false);
    });
}
