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

  if $('[data-behavior~=mentionable]').length
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

  comments = $('[data-behavior~=comment-feed] [data-author]')
  if comments.length
    current_user = $('meta[name=current-user-id]').attr('content')
    for comment in comments
      comment = $(comment)
      if `current_user == comment.data('author')`
        comment.find('.actions').addClass('current_user')
