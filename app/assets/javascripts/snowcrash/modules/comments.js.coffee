document.addEventListener "turbolinks:load", ->

  # hide comment editable textarea when clicking cancel
  $('.comment-feed').on('click', "[data-behavior~=cancel-comment]", ->
    element = $(this)
    comment = element.closest(".comment")
    comment.find(".content").show()
    comment.find("form").hide()
  )

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
