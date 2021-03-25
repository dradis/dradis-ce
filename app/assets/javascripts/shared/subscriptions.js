document.addEventListener('turbolinks:load', function() {
  const callback = function(mutationsList, observer) {
    mutationsList.forEach(function(mutationRecord) {
      var behavior = mutationRecord.target.dataset.behavior;

      // Find the node that triggered the fetch event.
      if (behavior && behavior.includes('fetch')) {
        mutationRecord.target.querySelectorAll('[data-behavior~=subscription-actions]').forEach(function(item) {
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

    observer.disconnect();
  };

  // Select the node that will be observed for mutations
  document.querySelectorAll('[data-behavior~=fetch]').forEach(function(item) {
    var config = { childList: true, subtree: true };

    const observer = new MutationObserver(callback);

    observer.observe(item, config);
  });
});
