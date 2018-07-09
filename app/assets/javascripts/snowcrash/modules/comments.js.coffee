document.addEventListener "turbolinks:load", ->
  # new comments may be added AJAX after page load, so make sure that
  # the event handler will catch clicks for all of them:
  $('.comment-feed').on 'click', '[data-toggle-comment]', ->
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
