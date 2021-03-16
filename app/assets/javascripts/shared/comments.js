class Comments {
  constructor() {
    this.init();
  }

  init() {
    // hide comment editable textarea when clicking cancel
    $('[data-behavior~=comment]').on('click', '[data-behavior~=cancel-comment]', function() {
      var $element = $(this);
      var $comment = $element.closest('.comment');
      $comment.find('.content').show();
      $comment.find('form').hide();
      $comment.find('[data-action~=edit]').show();
    })

    if ($('[data-behavior~=mentionable]').length) {
      Mentions.init(document.querySelectorAll('[data-behavior~=mentionable]'));
    }

    var $currentUserComments = $('[data-behavior~=comment] [data-author-id]');

    if ($currentUserComments.length) {
      var currentUserId = $('meta[name=current-user-id]').attr('content');

      $currentUserComments.each(function() {
        var $comment = $(this);
        var commentAuthorId = $comment.data('author-id');

        if (currentUserId == commentAuthorId) {
          $comment.find('.actions').addClass('current_user');
        }
      })
    }
  }
}

document.addEventListener('turbolinks:load', function() {
  new Comments;
})

