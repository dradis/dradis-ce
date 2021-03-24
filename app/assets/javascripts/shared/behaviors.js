(function($, window){
  function initBehaviors(parentElement) {
    //Activate jQuery.Textile
    $('.textile').textile();

    // Activate Rich Toolbars for the editor
    $('[data-behavior~=rich-toolbar]').each(function() {
      new EditorToolbar($(this));
    });

    // Activate local auto save
    $('[data-behavior~=local-auto-save]').each(function() {
      new LocalAutoSave(this);
    });

    parentElement.querySelectorAll('[data-behavior~=comment-feed] [data-author-id]').forEach(function(item) {
      var currentUserId = document.querySelector('meta[name=current-user-id]').getAttribute('content');

      if (item.dataset.authorId === currentUserId) {
        var actions = item.querySelector('.actions');
        actions.classList.add('current_user');
      }
    });

    // Activate mentions
    var mentionables = parentElement.querySelectorAll('[data-behavior~=mentionable]');
    if (mentionables.length) {
      Mentions.init(mentionables);
    }

    parentElement.querySelectorAll('[data-behavior~=fetch]').forEach(function(item) {
      fetch(item.dataset.path, { credentials: 'include' })
        .then(function(response) { return response.text(); })
        .then(function(html) {
          item.innerHTML = html;
          initBehaviors(item);
        });
    });
  }

  document.addEventListener('turbolinks:load', function() {
    initBehaviors(document.querySelector('body'));
  });
})($, window);
