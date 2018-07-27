document.addEventListener "turbolinks:load", ->

  # hide/show comment editable textarea
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

  # initialize mentions (https://github.com/zurb/tribute)
  tribute = new Tribute(
    allowSpaces: ->
      false
    menuItemTemplate: (item) ->
      '<img src="' + item.original.avatar_url + '" width="24px" height="24px" > ' + item.string
    noMatchTemplate: ->
      ''
    values: $('#mentionable-users').data('users')
  )
  tribute.attach(document.querySelectorAll('[data-behavior~=mentionable]'));
