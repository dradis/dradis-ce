# Timeline of events:
#
# 0. (First time only, on page load:) ActivitiesPoller is initialized,
#    and `last_poll` is set to the current timestamp.
# 1. ActivityPoller.poll() is called, either on page load (document.ready)
#    or by `ActivitiesController -> index.js.erb`
# 2. ActivityPoller waits for POLLING_INTERVAL_MS, then makes a request to the
#    server.
# 3. ActivitiesController#poll loads all Activities that were created since
#    'last_poll', and passes activity data back to the frontend, which
#    updates the views.
# 4. The front-end updates 'last_poll' to the time at which step 3 took place.
# 5. Repeat from step 1.
#
class @ActivitiesPoller
  POLLING_INTERVAL_MS = 10000

  @init: ($poller)->
    @initialized  = true
    # Current action name
    @action       = $poller.data("action")
    # Current board, if there is one. This might not be present.
    @boardId      = $poller.data('board-id')
    # Current board name, if there is one. This might not be present.
    @boardName    = $poller.data('board-name')
    # Current board path, if there is one. This might not be present.
    @boardPath    = $poller.data('board-path')
    # Current boards path
    @boardsPath   = $poller.data('boards-path')
    # Current card, if there is one. This might not be present.
    @cardId       = $poller.data('card-id')
    # Current card path, if there is one. This might not be present.
    @cardPath     = $poller.data('card-path')
    # Current controller name
    @controller   = $poller.data("controller")
    # Current list, if there is one. This might not be present.
    @listId       = $poller.data('list-id')
    # Current list name, if there is one. This might not be present.
    @listName     = $poller.data('list-name')
    # The ID of the Note, Node, Evidence etc that we're currently
    # viewing/editing (if there is one):
    @modelId      = $poller.data("id")
    # Current node, if there is one. (If we're looking at a Note or Evidence
    # this will be the ID of the parent node). This might not be present,
    # e.g. on projects#show or the import/export pages.
    @nodeId       = $poller.data('node-id')
    @url          = $poller.data('url')
    # Unix timestamp integer of the last time the poller was called. (We need
    # to load all relevant activities which were created since this time)
    @lastPoll     = $poller.data('last-poll')
    unless @url? && @action? && @controller?
      throw "Activity poller not configured correctly"
    @


  @poll: ->
    self = this
    setTimeout (-> self.request()), POLLING_INTERVAL_MS


  @request: ->
    $.get @url, { last_poll: @lastPoll }


  @setAfter: (val) ->
    @after = (val)

  # ------ NODES ------

  @addRootNode: (linkContent) ->
    # Note this selector will match two elements (the tree in the sidebar
    # and the tree in the modal) and append the new link to both:
    $(".nodes-nav.tree-navigation").append(linkContent)


  @addSubNode: (parentId, linkContent) ->
    @_findNodeLinks(parentId).each (i, link) ->
      $link = $(link)
      $toggleLink = $link.children(".toggle")
      $subNodes   = $link.children("ul.children")
      if $toggleLink.css("visibility") != "hidden"
        # (Note: We're using '.children', not '.find', because we only
        # want to check subnodes that are one level down from the current node)
        unless $subNodes.children(".loading").length
          # If we've reached this point, that means the user has already loaded
          # the siblings of this new node using tree.js. (If they hadn't, we wouldn't
          # need to do anything here, since the new subnode will be lazily-loaded
          # anyway when they do expand the parent node.)
          $subNodes.append(linkContent)
      else
        # If $toggleLink is hidden, then the parent node has previously been
        # expanded, but had no children. Show the toggler again so the user can
        # re-expand the tree (this time showing the new subnode):
        # Also make sure the toggle link is pointing the right way
        #
        # (Note that the following JS is just a reverse of what happens
        # in app/views/nodes/tree.js.erb and jquery.treenav.js.coffee)
        $toggleLink
          .css("visibility", "")
          .addClass("hasSubmenu")
        $toggleLink.children("i")
          .removeClass("fa-caret-down")
          .addClass("fa-caret-right")
        $toggleLink.find('li.loading').removeClass('d-none')
        $toggleLink.find('li.error').addClass('d-none')
        $subNodes.removeClass("opened")


  @updateNode: (nodeId, linkContent) ->
    $links = @_findNodeLinks(nodeId)
    $links.replaceWith(linkContent)

    if @nodeId == nodeId
      $links.addClass('active')


  @deleteNode: (nodeId) ->
    $links = @_findNodeLinks(nodeId)
    if @nodeId == nodeId
      $links.find('a').attr('href', '#')
      @_showNodeDeletedAlert()
    else
      # We need to remove the link from both the sidebar and the 'move node'
      # modal, but both links have the same ID (see _node.html.erb). So we need
      # to use a more complicated selector if we want to find both of them:
      $links.each (i, link) ->
        $link = $(link)
        # Adjust parent style / remove caret
        $parent = $link.parents('li').first()
        sibling_count = $parent.find('ul li').length
        $link.remove()
        if sibling_count == 1
          $parent.removeClass('hasSubmenu')
          $parent.find('.toggle').replaceWith('<span class="toggle">&nbsp;</span>')


  # ------ NOTES ------

  @addNote: (nodeId, linkForSidebar) ->
    if @nodeId == nodeId
      @_addLink("notes", linkForSidebar)


  @updateNote: (nodeId, noteId, newLink) ->
    if @nodeId == nodeId
      @_findNoteLink(noteId).replaceWith(newLink)

      if @_currentlyViewingNote(noteId)
        $("#note-updated-alert").removeClass('d-none')


  @deleteNote: (noteId) ->
    $link = @_findNoteLink(noteId)
    if $link.length
      $link.remove()
      if ($('#notes .list-item').length == 1)
        $('#notes .placeholder').slideDown(300)

      if @_currentlyViewingNote(noteId)
        @_showNoteDeletedAlert()


  # ------ EVIDENCE ------

  @addEvidence: (nodeId, linkForSidebar) ->
    if @nodeId == nodeId
      @_addLink("evidence", linkForSidebar)


  @updateEvidence: (nodeId, evidenceId, newLink, content) ->
    if @nodeId == nodeId
      @_findEvidenceLink(evidenceId).replaceWith(newLink)

      if @_currentlyViewingEvidence(evidenceId)
        $("#evidence-updated-alert").removeClass('d-none')


  @deleteEvidence: (evidenceId) ->
    $link = @_findEvidenceLink(evidenceId)
    if $link.length
      $link.remove()
      if ($('#evidence .list-item').length == 1)
        $('#notes .placeholder').slideDown(300)

    if @_currentlyViewingEvidence(evidenceId)
      @_showEvidenceDeletedAlert()


  # ------ CARDS ------

  @addCard: (listId, boardId, linkForSidebar) ->
    if @controller == 'cards' && @listId == listId # card added to current list
      @_addLink('tasks', linkForSidebar)

    else if @_currentlyViewingBoard(boardId)
      @_refreshBoard(boardId)


  @deleteCard: (cardId) ->
    if @controller == 'cards' # viewing cards, a card was deleted
      $link = @_findCardLink(cardId)
      if $link.length # if the card was on current list (link present) remove it
        @_removeCardLink($link)
      if @_currentlyViewingCard(cardId) # if it was the current card, warn
        @_showCardDeletedAlert()

    else if @controller in ['boards', 'nodes']
      $link = $(".card[data-card-id='#{cardId}']")
      if $link.length
        $link.remove()


  @updateCard: (cardId, listId, boardId, linkForSidebar) ->
    if @controller == 'cards' # viewing cards, a card was moved
      $link = @_findCardLink(cardId)
      if @listId == listId # if card updated/moved in current list
        if !$link.length # if sidebar link not yet present, add it
          @_addLink('tasks', linkForSidebar)
        else
          $link.replaceWith(linkForSidebar)
      else # card updated/moved in another list
        if $link.length # if sidebar link present, remove it
          @_removeCardLink($link)

      if @_currentlyViewingCard(cardId) # if it was the current card
        if @action == 'show' # update card when viewing it
          @_refreshCard(cardPath)
        else # warn if editing it
          message =
            "<p>
              <strong>Warning</strong>. This task has been updated by another user
              since you started viewing it. Check its most recent version
              <strong><a href='#{cardPath}'>here</a></strong>.
            </p>"
          $('#card-updated-alert').html(message)
          $('#card-updated-alert').removeClass('d-none')

    else if @_currentlyViewingBoard(boardId)
      @_refreshBoard(boardId)


  # ------ BOARDS ------

  @deleteBoard: (boardId) ->
    if @controller in ['cards', 'nodes'] && boardId == @boardId
        @_showBoardDeletedAlert()

    else if @controller == "boards"
      if @action == "index"
        $board = $("li.board-list-item[data-board-id='#{boardId}']")
        if $board.length
          $board.remove()
      else if @_currentlyViewingBoard(boardId)
        @_showBoardDeletedAlert()

  @updateBoard: (boardId, boardName) ->
    if @controller == 'boards'
      if @action == 'index'
        $board = $("li.board-list-item[data-board-id='#{boardId}']")
        if $board.length
          $board.find('.board-tile-details-name').html(boardName)
      else if @_currentlyViewingBoard(boardId)
        document.title = boardName
        $('#view-content h3').html(boardName)
        $('ol.breadcrumb li:nth-child(2)').html(boardName)

    if @controller == 'nodes' && @_currentlyViewingBoard(boardId)
        $('[data-behavior~=board-name]').html(boardName)

    else if @controller == 'cards' && boardId == @boardId
      if @action == 'show'
        @_refreshCard()
      else
        $("ul.breadcrumb li:nth-child(2) a").html("#{boardName} - #{@listName}")


  @addBoard: (boardId) ->
    if @controller == "boards" && @action == "index"
      @_refreshBoardIndex()


  # ------ LISTS ------

  @deleteList: (listId) ->
    if @controller == 'cards' && listId == @listId
      @_showListDeletedAlert()

    else if @controller in ['boards', 'nodes']
      $list = $("li.list[data-list-id='#{listId}']")
      if $list.length
        $list.remove()


  @updateList: (listId, boardId, listName) ->
    if @_currentlyViewingBoard(boardId)
      @_refreshBoard(boardId)
    else if @controller == 'cards' && @listId == listId
      if @action == 'show'
        @_refreshCard(@cardId, listId, boardId)
      else
        $("ul.breadcrumb li:nth-child(2) a").html("#{@boardName} - #{listName}")


  @addList: (listId, boardId) ->
    if @_currentlyViewingBoard(boardId)
      @_refreshBoard(boardId)


  # ------ COMMENTS ------

  @addComment: (commentableId, content) ->
    # Make sure comment isn't already on the page, e.g. if they
    # loaded/refreshed the page just after the comment was posted:
    if commentableId == @modelId && !$("#comment_#{commentId}").length
      $('[data-notice~=no-comments]').hide()
      $('.comment-list').append(content)
      count = parseInt($('#comment-count').html())
      $('#comment-count').html(count + 1)

  @updateComment: (commentId, commentableId, content) ->
    comment = $("#comment_#{commentId}")
    comment.replaceWith(content)

  @deleteComment: (commentId) ->
    comment = $("#comment_#{commentId}")
    if comment.length
      comment.remove()
      count = parseInt($('#comment-count').html())
      count = count - 1 if count > 0
      $('#comment-count').html(count)
      $('[data-notice~=no-comments]').removeClass('d-none') if count == 0

  # private

  @_addLink: (selector, link) ->
    $("##{selector}").append(link)
    $("##{selector} .placeholder").hide()


  @_removeCardLink: (link) ->
    link.remove()
    if ($('#tasks .list-item').length == 1)
      $('#tasks .placeholder').slideDown(300)


  @_currentlyViewingBoard: (boardId) ->
    (@controller == "boards" && @modelId == boardId) ||
    (@controller == "nodes" && @boardId == boardId)


  @_currentlyViewingCard: (cardId) ->
    @controller == "cards" && @modelId == cardId


  @_currentlyViewingEvidence: (evidenceId) ->
    @controller == "evidence" && @modelId == evidenceId


  @_currentlyViewingNote: (noteId) ->
    @controller == "notes" && @modelId == noteId


  # Find and return the links to the node with the given ID, in the sidebar and
  # in the 'move node' modal
  @_findNodeLinks: (nodeId) ->
    # Note that there will be TWO elements with the HTML ID "node_X" - one
    # within the sidebar and one within the move mode modal. This is why we're
    # using the strange selector "[id='node_X']" instead of just "#node_X" -
    # the former will return both elements, the latter will only return the
    # first.
    $("[id='node_#{nodeId}']")


  @_findNoteLink: (noteId) ->
    $("#note_#{noteId}_link")


  @_findEvidenceLink: (evidenceId) ->
    $("#evidence_#{evidenceId}_link")


  @_findCardLink: (cardId) ->
    $("#card_#{cardId}_link")


  @_refreshBoard: (boardId) ->
    # FIXME: use Turbolinks.visit("...") and a turbolinks event ?
    $.get @boardPath, (html) ->
      $("ul.board[data-board-id='#{boardId}']").replaceWith(html)
      $(document).trigger 'sortable:init'


  @_refreshBoardIndex: () ->
    # FIXME: use Turbolinks.visit("...") and a turbolinks event ?
    $.get @boardsPath, (html) ->
      $("ul.board-list").replaceWith(html)
      $(document).trigger 'sortable:init'


  @_refreshCard: (cardPath = @cardPath) ->
    # FIXME: use Turbolinks.visit("...") and a turbolinks event?
    $.get cardPath, (html) ->
      $("#js-card").replaceWith(html)
      $(document).trigger 'sortable:init'

      breadcrumbs = $(html).find("[data-behavior~=breadcrumbs-xhr]").html()
      $("[data-behavior~=breadcrumbs-nav]").replaceWith(breadcrumbs)


  @_showEvidenceDeletedAlert: ->
    $("#evidence-updated-alert").addClass('d-none')
    $("#evidence-deleted-alert").removeClass('d-none')


  @_showNoteDeletedAlert: ->
    $("#note-updated-alert").addClass('d-none')
    $("#note-deleted-alert").removeClass('d-none')


  @_showNodeDeletedAlert: ->
    $('#node-deleted-alert').removeClass('d-none')


  @_showBoardDeletedAlert: ->
    $("#board-deleted-alert").removeClass('d-none')


  @_showCardDeletedAlert: ->
    $("#card-updated-alert").addClass('d-none')
    $("#card-deleted-alert").removeClass('d-none')


  @_showListDeletedAlert: ->
    $("#list-deleted-alert").removeClass('d-none')
