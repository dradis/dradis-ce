document.addEventListener('turbolinks:load', function() {
  document.addEventListener('DOMNodeInserted', function(e) {
    var parentNode = e.target.parentNode;
    var behavior = parentNode.dataset.behavior;

    if (behavior && behavior.includes('fetch')) {
      document.querySelectorAll('[data-behavior~=subscription-actions]').forEach(function(item) {
        // Vanilla js returns a string while jquery returns a boolean instead
        if (item.dataset.subscribed === 'true') {
          document.querySelectorAll('[data-behavior=unsubscribe]').forEach(function(item) {
            item.classList.remove('d-none');
          });
        } else {
          document.querySelectorAll('[data-behavior=subscribe]').forEach(function(item) {
            item.classList.remove('d-none');
          });
        }
      });
    }
  });
});
