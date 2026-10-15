// The dots-menu Subscribe/Unsubscribe items live in fragment caches shared by
// every user, so both are rendered hidden. The comments header is rendered per
// user, so use it to reveal the right one.
$(document).on('dradis:fetch', '[data-behavior~=fetch-comments]', (event) => {
  const header = event.target.querySelector('[data-behavior~=subscriptions-header]');
  if (!header) return;

  // dataset returns a string, not a boolean
  const behavior = header.dataset.subscribed === 'true' ? 'unsubscribe' : 'subscribe';
  document.querySelectorAll(`[data-behavior~=${behavior}]`).forEach((item) => {
    item.classList.remove('d-none');
  });
});
