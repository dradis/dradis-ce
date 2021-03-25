document.addEventListener('turbolinks:load', function() {
  // https://stackoverflow.com/a/34896387
  document.addEventListener('click', function(e) {
    var element = e.target;

    if(element && element.dataset.behavior.includes('cancel-comment')) {
      var comment = e.target.parentNode.parentNode.parentNode;

      var form = comment.querySelector("form");
      form.remove();

      comment.querySelector(".content").style.display = '';
      comment.querySelector('[data-action~=edit]').style.display = '';
    }
  });

  const callback = function(mutationsList, observer) {
    mutationsList.forEach(function(mutationRecord) {
      var behavior = mutationRecord.target.dataset.behavior;

      // Find the node that triggered the fetch event.
      if (behavior && behavior.includes('fetch')) {
        mutationRecord.target.querySelectorAll('[data-behavior~=comment-feed] [data-author-id]').forEach(function(item) {
          var currentUserId = document.querySelector('meta[name=current-user-id]').getAttribute('content');

          if (item.dataset.authorId === currentUserId) {
            var actions = item.querySelector('.actions');
            actions.classList.add('current_user');
          }
        })

        mutationRecord.target.querySelectorAll('[data-behavior~=mentionable]').forEach(function(item) {
          Mentions.init($(item));
        })
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
})
