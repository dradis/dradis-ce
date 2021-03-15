class @Comments
  constructor: ->
    @init()

  init: ->
    # hide comment editable textarea when clicking cancel
    $('[data-behavior~=comment-feed]').on('click', '[data-behavior~=cancel-comment]', ->
      element = $(this)
      comment = element.closest(".comment")
      comment.find(".content").show()
      comment.find("form").hide()
      comment.find('[data-action~=edit]').show()
    )

    if $('[data-behavior~=mentionable]').length
      Mentions.init(document.querySelectorAll('[data-behavior~=mentionable]'))

    comments = $('[data-behavior~=comment-feed] [data-author]')
    if comments.length
      current_user = $('meta[name=current-user-id]').attr('content')
      for comment in comments
        comment = $(comment)
        if `current_user == comment.data('author')`
          comment.find('.actions').addClass('current_user')

document.addEventListener "turbolinks:load", ->
  new Comments
