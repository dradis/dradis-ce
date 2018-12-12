document.addEventListener "turbolinks:load", ->

  # hide comment editable textarea when clicking cancel
  $('.comment-feed').on('click', "[data-behavior~=cancel-comment]", ->
    element = $(this)
    comment = element.closest(".comment")
    comment.find(".content").show()
    comment.find("form").hide()
  )

  if $('[data-behavior~=mentionable]').length
    Mentions.init(document.querySelectorAll('[data-behavior~=mentionable]'))
