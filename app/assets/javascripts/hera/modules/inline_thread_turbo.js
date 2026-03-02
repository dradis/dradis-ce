/*
  InlineThreadTurbo

  Coordinates InlineThreadSelector and InlineThreadHighlighter using
  Turbo Frames and Turbo Streams for server-rendered responses.

  Replaces InlineThreadManager + InlineThreadPanel with a single
  coordinator that delegates rendering to the server.

  - Existing threads load into the panel via Turbo Frame (GET show)
  - New thread forms are built client-side (anchor data from selection)
    and submitted via Turbo (POST create → turbo_stream response)
  - Resolve/reopen/reply are server-rendered button_to/form_with
    inside the Turbo Frame, handled automatically by Turbo

  Usage:
    Initialized in hera/pages/qa.js on the QA issue show page.
*/

class InlineThreadTurbo {
  constructor(container) {
    this.container = container;
    this.threadsPath = container.dataset.inlineThreadsPath;
    this.basePath = container.dataset.inlineThreadsBasePath;

    this.panel = document.querySelector('[data-behavior~=inline-thread-panel]');
    this.frame = document.getElementById('inline_thread_content');

    var csrfMeta = document.querySelector('meta[name=csrf-token]');
    this.csrfToken = csrfMeta ? csrfMeta.content : '';

    var contentEl = container.querySelector('[data-behavior~=content-textile]');

    // Prevent QuoteSelector from binding to this content-textile element.
    // QuoteSelector's constructor checks this data attribute and bails if set.
    $(contentEl).data('quoteSelector', 'inline-thread');

    this.highlighter = new InlineThreadHighlighter(contentEl, this);
    this.selector = new InlineThreadSelector(container, this);

    this.bindEvents();
    this.fetchAndHighlight();
  }

  // -- Panel management ----------------------------------------------------

  openPanel() {
    this.panel.classList.add('open');
  }

  closePanel() {
    this.panel.classList.remove('open');
    this.frame.innerHTML = '';
  }

  // -- Thread display (via Turbo Frame) ------------------------------------

  showThread(threadId) {
    this.frame.src = this.basePath + '/' + threadId;
    this.openPanel();
  }

  showNewThreadForm(anchor) {
    this.frame.innerHTML = this.buildNewThreadForm(anchor);
    this.openPanel();

    var textarea = this.frame.querySelector('textarea');
    if (textarea) textarea.focus();
  }

  // -- Data fetching and highlighting --------------------------------------

  fetchAndHighlight() {
    var that = this;

    fetch(this.threadsPath, {
      headers: { 'Accept': 'application/json' }
    })
      .then(function (r) { return r.json(); })
      .then(function (threads) {
        that.highlighter.highlight(threads);
      });
  }

  // -- Events --------------------------------------------------------------

  bindEvents() {
    var that = this;

    // Close panel
    this.panel.addEventListener('click', function (e) {
      if (e.target.closest('[data-behavior~=close-inline-panel]')) {
        that.closePanel();
      }
    });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && that.panel.classList.contains('open')) {
        that.closePanel();
      }
    });

    // Liquid async rendering replaces innerHTML of content-textile,
    // destroying all <mark> highlights. Re-fetch and re-highlight.
    $(this.container).find('[data-behavior~=content-textile]').on(
      'dradis:liquid-rendered', function () {
        that.fetchAndHighlight();
      }
    );

    // After any Turbo form submission in our panel, re-highlight threads.
    // Turbo Streams have already updated the panel DOM by this point.
    document.addEventListener('turbo:submit-end', function (e) {
      if (!e.target.closest('[data-behavior~=inline-thread-panel]')) return;
      if (!e.detail.success) return;

      that.fetchAndHighlight();

      // Close panel if the thread was deleted (frame is now empty)
      setTimeout(function () {
        if (that.frame && !that.frame.querySelector('.inline-thread')) {
          that.closePanel();
        }
      }, 100);
    });
  }

  // -- Helpers -------------------------------------------------------------

  buildNewThreadForm(anchor) {
    return '<div class="inline-thread-new p-3">' +
      '<h6>New Comment Thread</h6>' +
      '<blockquote class="thread-quoted-text border-start border-3 border-primary ps-3 text-muted fst-italic">' +
        this.escapeHtml(anchor.exact) +
      '</blockquote>' +
      '<form action="' + this.basePath + '" method="post" accept-charset="UTF-8" data-turbo="true">' +
        '<input type="hidden" name="authenticity_token" value="' + this.csrfToken + '">' +
        this.buildAnchorFields(anchor) +
        '<div class="mb-2">' +
          '<textarea name="comment[content]" class="form-control form-control-sm" ' +
            'placeholder="Add a comment..." rows="3" required></textarea>' +
        '</div>' +
        '<div class="d-flex gap-2">' +
          '<button type="submit" class="btn btn-sm btn-primary">Create Thread</button>' +
          '<button type="button" class="btn btn-sm btn-outline-secondary" ' +
            'data-behavior="close-inline-panel">Cancel</button>' +
        '</div>' +
      '</form>' +
    '</div>';
  }

  buildAnchorFields(anchor) {
    var prefix = 'inline_comment_thread[anchor]';

    return '<input type="hidden" name="' + prefix + '[type]" value="' + this.escapeHtml(anchor.type) + '">' +
      '<input type="hidden" name="' + prefix + '[exact]" value="' + this.escapeHtml(anchor.exact) + '">' +
      '<input type="hidden" name="' + prefix + '[prefix]" value="' + this.escapeHtml(anchor.prefix) + '">' +
      '<input type="hidden" name="' + prefix + '[suffix]" value="' + this.escapeHtml(anchor.suffix) + '">' +
      '<input type="hidden" name="' + prefix + '[field_name]" value="' + this.escapeHtml(anchor.field_name || '') + '">' +
      '<input type="hidden" name="' + prefix + '[position][start]" value="' + anchor.position.start + '">' +
      '<input type="hidden" name="' + prefix + '[position][end]" value="' + anchor.position.end + '">';
  }

  escapeHtml(str) {
    if (!str) return '';
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }
}
