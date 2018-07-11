document.addEventListener "turbolinks:load", ->
  $feed = $('.comment-feed')

  # new comments may be added AJAX after page load, so make sure that
  # the event handler will catch clicks for all of them:
  $feed.on 'click', '[data-toggle-comment]', ->
    element = $(this)
    comment = element.closest(".comment")
    content = comment.find(".content")
    update  = comment.find(".edit_comment")
    value   = element.data('toggle-comment')
    if value == "on"
      content.hide()
      update.show()
    else if value == "off"
      content.show()
      update.hide()


  # Hide the 'action' buttons from all comments which don't belong to the
  # current user
  currentUserId = $('body').data('currentUserId')
  $feed.find('.comment').each ->
    $comment = $(this)
    unless $comment.data('userId') == currentUserId
      $comment.find('.actions, .edit_comment').remove()
