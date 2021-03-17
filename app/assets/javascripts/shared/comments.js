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

    var $userComments = $('[data-behavior~=comment][data-author-id]');

    if ($userComments.length) {
      var currentUserId = $('meta[name=current-user-id]').attr('content');

      $userComments.each(function() {
        var $comment = $(this);
        var commentAuthorId = $comment.data('author-id');

        if (currentUserId == commentAuthorId) {
          $comment.find('.actions').addClass('current_user');
        }
      })
    }
  }
}
