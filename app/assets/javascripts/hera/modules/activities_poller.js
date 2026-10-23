// Timeline of events:
//
// 0. (First time only, on page load:) ActivitiesPoller is initialized,
//    and `last_poll` is set to the current timestamp.
// 1. ActivityPoller.poll() is called, either on page load (document.ready)
//    or by `ActivitiesController -> index.js.erb`
// 2. ActivityPoller waits for POLLING_INTERVAL_MS, then makes a request to the
//    server.
// 3. ActivitiesController#poll loads all Activities that were created since
//    'last_poll', and passes activity data back to the frontend, which
//    updates the views.
// 4. The front-end updates 'last_poll' to the time at which step 3 took place.
// 5. Repeat from step 1.
//
class ActivitiesPoller {
  static POLLING_INTERVAL_MS = 10000;

  static init($poller) {
    this.initialized = true;
    // Current action name
    this.action = $poller.data('action');
    // Current board, if there is one. This might not be present.
    this.boardId = $poller.data('board-id');
    // Current board name, if there is one. This might not be present.
    this.boardName = $poller.data('board-name');
    // Current board path, if there is one. This might not be present.
    this.boardPath = $poller.data('board-path');
    // Current boards path
    this.boardsPath = $poller.data('boards-path');
    // Current card, if there is one. This might not be present.
    this.cardId = $poller.data('card-id');
    // Current card path, if there is one. This might not be present.
    this.cardPath = $poller.data('card-path');
    // Current controller name
    this.controller = $poller.data('controller');
    // Current list, if there is one. This might not be present.
    this.listId = $poller.data('list-id');
    // Current list name, if there is one. This might not be present.
    this.listName = $poller.data('list-name');
    // The ID of the Note, Node, Evidence etc that we're currently
    // viewing/editing (if there is one):
    this.modelId = $poller.data('id');
    // Current node, if there is one. (If we're looking at a Note or Evidence
    // this will be the ID of the parent node). This might not be present,
    // e.g. on projects#show or the import/export pages.
    this.nodeId = $poller.data('node-id');
    this.url = $poller.data('url');
    // Unix timestamp integer of the last time the poller was called. (We need
    // to load all relevant activities which were created since this time)
    this.lastPoll = $poller.data('last-poll');
    if (this.url == null || this.action == null || this.controller == null) {
      throw 'Activity poller not configured correctly';
    }
    return this;
  }

  static poll() {
    setTimeout(() => this.request(), this.POLLING_INTERVAL_MS);
  }

  static request() {
    return $.get(this.url, { last_poll: this.lastPoll });
  }

  static setAfter(val) {
    this.after = val;
  }

  // ------ NODES ------

  static addRootNode(linkContent) {
    // Note this selector will match two elements (the tree in the sidebar
    // and the tree in the modal) and append the new link to both:
    $('.nodes-nav.tree-navigation').append(linkContent);
  }

  static addSubNode(parentId, linkContent) {
    this._findNodeLinks(parentId).each((i, link) => {
      const $link = $(link);
      const $toggleLink = $link.children('.toggle');
      const $subNodes = $link.children('ul.children');
      if ($toggleLink.css('visibility') !== 'hidden') {
        // (Note: We're using '.children', not '.find', because we only
        // want to check subnodes that are one level down from the current node)
        if (!$subNodes.children('.loading').length) {
          // If we've reached this point, that means the user has already loaded
          // the siblings of this new node using tree.js. (If they hadn't, we wouldn't
          // need to do anything here, since the new subnode will be lazily-loaded
          // anyway when they do expand the parent node.)
          $subNodes.append(linkContent);
        }
      } else {
        // If $toggleLink is hidden, then the parent node has previously been
        // expanded, but had no children. Show the toggler again so the user can
        // re-expand the tree (this time showing the new subnode):
        // Also make sure the toggle link is pointing the right way
        //
        // (Note that the following JS is just a reverse of what happens
        // in app/views/nodes/tree.js.erb and jquery.treenav.js.coffee)
        $toggleLink.css('visibility', '').addClass('hasSubmenu');
        $toggleLink.children('i').removeClass('fa-caret-down').addClass('fa-caret-right');
        $toggleLink.find('li.loading').removeClass('d-none');
        $toggleLink.find('li.error').addClass('d-none');
        $subNodes.removeClass('opened');
      }
    });
  }

  static updateNode(nodeId, linkContent) {
    const $links = this._findNodeLinks(nodeId);
    $links.replaceWith(linkContent);

    if (this.nodeId === nodeId) {
      $links.addClass('active');
    }
  }

  static deleteNode(nodeId) {
    const $links = this._findNodeLinks(nodeId);
    if (this.nodeId === nodeId) {
      $links.find('a').attr('href', '#');
      this._showNodeDeletedAlert();
    } else {
      // We need to remove the link from both the sidebar and the 'move node'
      // modal, but both links have the same ID (see _node.html.erb). So we need
      // to use a more complicated selector if we want to find both of them:
      $links.each((i, link) => {
        const $link = $(link);
        // Adjust parent style / remove caret
        const $parent = $link.parents('li').first();
        const siblingCount = $parent.find('ul li').length;
        $link.remove();
        if (siblingCount === 1) {
          $parent.removeClass('hasSubmenu');
          $parent.find('.toggle').replaceWith('<span class="toggle">&nbsp;</span>');
        }
      });
    }
  }

  // ------ NOTES ------

  static addNote(nodeId, linkForSidebar) {
    if (this.nodeId === nodeId) {
      this._addLink('notes', linkForSidebar);
    }
  }

  static updateNote(nodeId, noteId, newLink) {
    if (this.nodeId === nodeId) {
      this._findNoteLink(noteId).replaceWith(newLink);

      if (this._currentlyViewingNote(noteId)) {
        $('#note-updated-alert').removeClass('d-none');
      }
    }
  }

  static deleteNote(noteId) {
    const $link = this._findNoteLink(noteId);
    if ($link.length) {
      $link.remove();
      if ($('#notes .list-item').length === 1) {
        $('#notes .dradis-placeholder').slideDown(300);
      }

      if (this._currentlyViewingNote(noteId)) {
        this._showNoteDeletedAlert();
      }
    }
  }

  // ------ EVIDENCE ------

  static addEvidence(nodeId, linkForSidebar) {
    if (this.nodeId === nodeId) {
      this._addLink('evidence', linkForSidebar);
    }
  }

  static updateEvidence(nodeId, evidenceId, newLink, content) {
    if (this.nodeId === nodeId) {
      this._findEvidenceLink(evidenceId).replaceWith(newLink);

      if (this._currentlyViewingEvidence(evidenceId)) {
        $('#evidence-updated-alert').removeClass('d-none');
      }
    }
  }

  static deleteEvidence(evidenceId) {
    const $link = this._findEvidenceLink(evidenceId);
    if ($link.length) {
      $link.remove();
      if ($('#evidence .list-item').length === 1) {
        $('#notes .dradis-placeholder').slideDown(300);
      }
    }

    if (this._currentlyViewingEvidence(evidenceId)) {
      this._showEvidenceDeletedAlert();
    }
  }

  // ------ CARDS ------

  static addCard(listId, boardId, linkForSidebar) {
    if (this.controller === 'cards' && this.listId === listId) {
      // card added to current list
      this._addLink('tasks', linkForSidebar);
    } else if (this._currentlyViewingBoard(boardId)) {
      this._refreshBoard(boardId);
    }
  }

  static deleteCard(cardId) {
    if (this.controller === 'cards') {
      // viewing cards, a card was deleted
      const $link = this._findCardLink(cardId);
      if ($link.length) {
        // if the card was on current list (link present) remove it
        this._removeCardLink($link);
      }
      if (this._currentlyViewingCard(cardId)) {
        // if it was the current card, warn
        this._showCardDeletedAlert();
      }
    } else if (['boards', 'nodes'].includes(this.controller)) {
      const $link = $(`.card[data-card-id='${cardId}']`);
      if ($link.length) {
        $link.remove();
      }
    }
  }

  static updateCard(cardId, listId, boardId, linkForSidebar) {
    if (this.controller === 'cards') {
      // viewing cards, a card was moved
      const $link = this._findCardLink(cardId);
      if (this.listId === listId) {
        // if card updated/moved in current list
        if (!$link.length) {
          // if sidebar link not yet present, add it
          this._addLink('tasks', linkForSidebar);
        } else {
          $link.replaceWith(linkForSidebar);
        }
      } else if ($link.length) {
        // card updated/moved in another list: if sidebar link present, remove it
        this._removeCardLink($link);
      }

      if (this._currentlyViewingCard(cardId)) {
        // if it was the current card
        // `cardPath` is a global set by activities/_poll_methodologies.js.erb
        if (this.action === 'show') {
          // update card when viewing it
          this._refreshCard(cardPath);
        } else {
          // warn if editing it
          const message = `<p>
              <strong>Warning</strong>. This task has been updated by another user
              since you started viewing it. Check its most recent version
              <strong><a href='${cardPath}'>here</a></strong>.
            </p>`;
          $('#card-updated-alert').html(message);
          $('#card-updated-alert').removeClass('d-none');
        }
      }
    } else if (this._currentlyViewingBoard(boardId)) {
      this._refreshBoard(boardId);
    }
  }

  // ------ BOARDS ------

  static deleteBoard(boardId) {
    if (['cards', 'nodes'].includes(this.controller) && boardId === this.boardId) {
      this._showBoardDeletedAlert();
    } else if (this.controller === 'boards') {
      if (this.action === 'index') {
        const $board = $(`li.board-list-item[data-board-id='${boardId}']`);
        if ($board.length) {
          $board.remove();
        }
      } else if (this._currentlyViewingBoard(boardId)) {
        this._showBoardDeletedAlert();
      }
    }
  }

  static updateBoard(boardId, boardName) {
    if (this.controller === 'boards') {
      if (this.action === 'index') {
        const $board = $(`li.board-list-item[data-board-id='${boardId}']`);
        if ($board.length) {
          $board.find('.board-tile-details-name').html(boardName);
        }
      } else if (this._currentlyViewingBoard(boardId)) {
        document.title = boardName;
        $('[data-behavior~=view-content] h3').html(boardName);
        $('ol.breadcrumb li:nth-child(2)').html(boardName);
      }
    }

    if (this.controller === 'nodes' && this._currentlyViewingBoard(boardId)) {
      $('[data-behavior~=board-name]').html(boardName);
    } else if (this.controller === 'cards' && boardId === this.boardId) {
      if (this.action === 'show') {
        this._refreshCard();
      } else {
        $('ul.breadcrumb li:nth-child(2) a').html(`${boardName} - ${this.listName}`);
      }
    }
  }

  static addBoard(boardId) {
    if (this.controller === 'boards' && this.action === 'index') {
      this._refreshBoardIndex();
    }
  }

  // ------ LISTS ------

  static deleteList(listId) {
    if (this.controller === 'cards' && listId === this.listId) {
      this._showListDeletedAlert();
    } else if (['boards', 'nodes'].includes(this.controller)) {
      const $list = $(`li.list[data-list-id='${listId}']`);
      if ($list.length) {
        $list.remove();
      }
    }
  }

  static updateList(listId, boardId, listName) {
    if (this._currentlyViewingBoard(boardId)) {
      this._refreshBoard(boardId);
    } else if (this.controller === 'cards' && this.listId === listId) {
      if (this.action === 'show') {
        this._refreshCard(this.cardId, listId, boardId);
      } else {
        $('ul.breadcrumb li:nth-child(2) a').html(`${this.boardName} - ${listName}`);
      }
    }
  }

  static addList(listId, boardId) {
    if (this._currentlyViewingBoard(boardId)) {
      this._refreshBoard(boardId);
    }
  }

  // ------ COMMENTS ------

  static addComment(commentableId, content) {
    // Make sure comment isn't already on the page, e.g. if they
    // loaded/refreshed the page just after the comment was posted:
    // `commentId` is a global set by activities/poll.js.erb
    if (commentableId === this.modelId && !$(`#comment_${commentId}`).length) {
      $('[data-notice~=no-comments]').addClass('d-none');
      $('[data-behavior~=comment-list]').append(content);
      const $count = $('[data-behavior~=comment-count]');
      $count.html(parseInt($count.html()) + 1);
    }
  }

  static updateComment(commentId, commentableId, content) {
    const comment = $(`#comment_${commentId}`);
    comment.replaceWith(content);
  }

  static deleteComment(commentId) {
    const comment = $(`#comment_${commentId}`);
    if (comment.length) {
      comment.remove();
      const $count = $('[data-behavior~=comment-count]');
      let count = parseInt($count.html());
      if (count > 0) {
        count = count - 1;
      }
      $count.html(count);
      $('[data-notice~=no-comments]').toggleClass('d-none', count > 0);
    }
  }

  // private

  static _addLink(selector, link) {
    $(`#${selector}`).append(link);
    $(`#${selector} .dradis-placeholder`).hide();
  }

  static _removeCardLink(link) {
    link.remove();
    if ($('#tasks .list-item').length === 1) {
      $('#tasks .dradis-placeholder').slideDown(300);
    }
  }

  static _currentlyViewingBoard(boardId) {
    return (
      (this.controller === 'boards' && this.modelId === boardId) ||
      (this.controller === 'nodes' && this.boardId === boardId)
    );
  }

  static _currentlyViewingCard(cardId) {
    return this.controller === 'cards' && this.modelId === cardId;
  }

  static _currentlyViewingEvidence(evidenceId) {
    return this.controller === 'evidence' && this.modelId === evidenceId;
  }

  static _currentlyViewingNote(noteId) {
    return this.controller === 'notes' && this.modelId === noteId;
  }

  // Find and return the links to the node with the given ID, in the sidebar and
  // in the 'move node' modal
  static _findNodeLinks(nodeId) {
    // Note that there will be TWO elements with the HTML ID "node_X" - one
    // within the sidebar and one within the move mode modal. This is why we're
    // using the strange selector "[id='node_X']" instead of just "#node_X" -
    // the former will return both elements, the latter will only return the
    // first.
    return $(`[id='node_${nodeId}']`);
  }

  static _findNoteLink(noteId) {
    return $(`#note_${noteId}_link`);
  }

  static _findEvidenceLink(evidenceId) {
    return $(`#evidence_${evidenceId}_link`);
  }

  static _findCardLink(cardId) {
    return $(`#card_${cardId}_link`);
  }

  static _refreshBoard(boardId) {
    // FIXME: use Turbolinks.visit("...") and a turbolinks event ?
    $.get(this.boardPath, (html) => {
      $(`ul.board[data-board-id='${boardId}']`).replaceWith(html);
      $(document).trigger('sortable:init');
    });
  }

  static _refreshBoardIndex() {
    // FIXME: use Turbolinks.visit("...") and a turbolinks event ?
    $.get(this.boardsPath, (html) => {
      $('ul.board-list').replaceWith(html);
      $(document).trigger('sortable:init');
    });
  }

  static _refreshCard(cardPath = this.cardPath) {
    // FIXME: use Turbolinks.visit("...") and a turbolinks event?
    $.get(cardPath, (html) => {
      $('#js-card').replaceWith(html);
      $(document).trigger('sortable:init');

      const breadcrumbs = $(html).find('[data-behavior~=breadcrumbs-xhr]').html();
      $('[data-behavior~=breadcrumbs-nav]').replaceWith(breadcrumbs);
    });
  }

  static _showEvidenceDeletedAlert() {
    $('#evidence-updated-alert').addClass('d-none');
    $('#evidence-deleted-alert').removeClass('d-none');
  }

  static _showNoteDeletedAlert() {
    $('#note-updated-alert').addClass('d-none');
    $('#note-deleted-alert').removeClass('d-none');
  }

  static _showNodeDeletedAlert() {
    $('#node-deleted-alert').removeClass('d-none');
  }

  static _showBoardDeletedAlert() {
    $('#board-deleted-alert').removeClass('d-none');
  }

  static _showCardDeletedAlert() {
    $('#card-updated-alert').addClass('d-none');
    $('#card-deleted-alert').removeClass('d-none');
  }

  static _showListDeletedAlert() {
    $('#list-deleted-alert').removeClass('d-none');
  }
}

window.ActivitiesPoller = ActivitiesPoller;
