document.addEventListener('turbolinks:load', function() {
  function subscriptionFeedObserverCallback(mutationsList, observer) {
    mutationsList.forEach(function(mutationRecord) {
      var target = mutationRecord.target;
      var behavior = target.dataset.behavior;

      // Initialize Mentions for the first time after fetch
      if (behavior && behavior.includes('fetch')) {
          target.querySelectorAll('[data-behavior~=subscription-actions]').forEach(function(item) {
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
  };

  // Select the node that will be observed for mutations
  document.querySelectorAll('[data-behavior~=fetch]').forEach(function(item) {
    // childList: observe changes in direct child
    // subtree: observe changes in descendants
    var config = { childList: true, subtree: true };

    const observer = new MutationObserver(subscriptionFeedObserverCallback);

    observer.observe(item, config);
  });
})
