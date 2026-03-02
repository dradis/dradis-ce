/*
  InlineThreadManager

  Coordinates InlineThreadSelector, InlineThreadHighlighter,
  and InlineThreadPanel. Provides callbacks for .js.erb responses
  via window.InlineThreadManager.

  Usage:
    Initialized in hera/pages/qa.js on the QA issue show page.
*/

class InlineThreadManager {
  constructor(container) {
    this.$container = $(container);
    this.threadsPath = this.$container.data('inline-threads-path');
    this.createPath = this.$container.data('inline-threads-create-path');
    this.currentUserId = this.$container.data('current-user-id');

    var csrfMeta = document.querySelector('meta[name=csrf-token]');
    this.csrfToken = csrfMeta ? csrfMeta.content : '';

    this.threads = [];

    var panelEl = document.querySelector('[data-behavior~=inline-thread-panel]');
    this.panel = new InlineThreadPanel(panelEl, {
      csrfToken: this.csrfToken,
      currentUserId: this.currentUserId
    });

    var contentEl = this.$container.find('[data-behavior~=content-textile]')[0];

    // Prevent QuoteSelector from binding to this content-textile element.
    // QuoteSelector's constructor checks this data attribute and bails if set.
    $(contentEl).data('quoteSelector', 'inline-thread');

    this.highlighter = new InlineThreadHighlighter(contentEl, this.panel);
    this.selector = new InlineThreadSelector(container, this.panel);

    // Register globally so .js.erb responses can call back
    window.InlineThreadManager = this;

    this.fetchAndHighlight();

    // Liquid async rendering replaces innerHTML of content-textile,
    // destroying all <mark> highlights. Re-fetch and re-highlight.
    var that = this;
    this.$container.find('[data-behavior~=content-textile]').on(
      'dradis:liquid-rendered', function () {
        that.fetchAndHighlight();
      }
    );
  }

  fetchAndHighlight() {
    var that = this;

    $.getJSON(this.threadsPath, function (threads) {
      that.threads = threads;
      that.highlighter.highlight(threads);
    });
  }

  // -- Callbacks from .js.erb responses ------------------------------------

  onThreadCreated(threadId) {
    this.panel.close();
    this.fetchAndHighlight();
  }

  onThreadDestroyed(threadId) {
    this.panel.close();
    this.fetchAndHighlight();
  }

  onThreadResolved(threadId) {
    this.panel.close();
    this.fetchAndHighlight();
  }

  onThreadReopened(threadId) {
    this.panel.close();
    this.fetchAndHighlight();
  }

  onCommentCreated(threadId, commentId) {
    var that = this;

    // Re-fetch threads to get updated data, then re-open the thread panel
    $.getJSON(this.threadsPath, function (threads) {
      that.threads = threads;
      that.highlighter.highlight(threads);

      // Find and re-open the thread that was just replied to
      var thread = threads.find(function (t) { return t.id === threadId; });
      if (thread) {
        that.panel.openExistingThread(thread);
      }
    });
  }

  onThreadError(message) {
    alert('Error: ' + message);
  }

  onCommentError(message) {
    alert('Error: ' + message);
  }
}
