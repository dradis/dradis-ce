class @Mentions
  @init: (elements) ->
    # initialize mentions (https://github.com/zurb/tribute)
    unless @tribute?
      @tribute = new Tribute(
        allowSpaces: ->
          false
        menuItemTemplate: (item) ->
          '<img src="' + item.original.avatar_url + '" width="24px" height="24px" > ' + item.string
        noMatchTemplate: ->
          ''
        values: JSON.parse($('meta[name=mentionable-users]').attr('content'))
      )

      $('.main-content').scroll ()=>
        @tribute.hideMenu()

    @tribute.attach(elements);
