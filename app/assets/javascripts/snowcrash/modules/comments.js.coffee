document.addEventListener "turbolinks:load", ->
  $("[data-toggle-comment]").click ->
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
