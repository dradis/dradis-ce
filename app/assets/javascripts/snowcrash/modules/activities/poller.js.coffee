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
    @initialized = true
    # Current controller name and action:
    @action      = $poller.data("action")
    @controller  = $poller.data("controller")
    # The ID of the Note, Node, Evidence etc that we're currently
    # viewing/editing (if there is one):
    @modelId     = $poller.data("id")
    # Current node, if there is one. (If we're looking at a Note or Evidence
    # this will be the ID of the parent node). This might not be present,
    # e.g. on projects#show or the import/export pages.
    @nodeId      = $poller.data('node-id')
    @url         = $poller.data('url')
    # Unix timestamp integer of the last time the poller was called. (We need
    # to load all relevant activities which were created since this time)
    @lastPoll    = $poller.data('last-poll')
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
        $toggleLink.find('li.loading').show()
        $toggleLink.find('li.error').hide()
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
        $("#note-updated-alert").show()


  @deleteNote: (noteId) ->
    $link = @_findNoteLink(noteId)
    if $link.length
      $link.remove()
      if ($('#notes .list-item').size() == 1)
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
        $("#evidence-updated-alert").show()


  @deleteEvidence: (evidenceId) ->
    $link = @_findEvidenceLink(evidenceId)
    if $link.length
      $link.remove()
      if ($('#evidence .list-item').size() == 1)
        $('#notes .placeholder').slideDown(300)

    if @_currentlyViewingEvidence(evidenceId)
      @_showEvidenceDeletedAlert()


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
      $('#comment-count').html(count - 1) if count > 0
      $('[data-notice~=no-comments]').show() if count == 0

  # private

  @_addLink: (selector, link) ->
    $("##{selector}").append(link)
    $("##{selector} .placeholder").hide()


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


  @_showEvidenceDeletedAlert: ->
    $("#evidence-updated-alert").hide()
    $("#evidence-deleted-alert").show()


  @_showNoteDeletedAlert: ->
    $("#note-updated-alert").hide()
    $("#note-deleted-alert").show()


  @_showNodeDeletedAlert: ->
    $('#node-deleted-alert').show()
