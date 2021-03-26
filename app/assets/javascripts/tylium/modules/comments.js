document.addEventListener('turbolinks:load', function() {
  function commentFeedObserverCallback(mutationsList, observer) {
    mutationsList.forEach(function(mutationRecord) {
      var target = mutationRecord.target;
      var behavior = target.dataset.behavior;

      // Initialize Mentions for the first time after fetch
      if (behavior && behavior.includes('fetch')) {
        target.querySelectorAll('[data-behavior~=mentionable]').forEach(function(item) {
          Mentions.init($(item));
        });
      }

      target.querySelectorAll('[data-behavior~=comment-feed] [data-author-id]').forEach(function(item) {
        var currentUserId = document.querySelector('meta[name=current-user-id]').getAttribute('content');

        if (item.dataset.authorId === currentUserId) {
          var actions = item.querySelector('.actions');
          actions.classList.add('current_user');
        }
      });
    });
  };

  // Select the node that will be observed for mutations
  document.querySelectorAll('[data-behavior~=fetch]').forEach(function(item) {
    // childList: observe changes in direct child
    // subtree: observe changes in descendants
    var config = { childList: true, subtree: true };

    const observer = new MutationObserver(commentFeedObserverCallback);

    observer.observe(item, config);
  });
})
