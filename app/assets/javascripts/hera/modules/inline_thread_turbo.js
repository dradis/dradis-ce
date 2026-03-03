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
    this.frame = document.querySelector('[data-behavior~=inline-thread-content]');

    const csrfMeta = document.querySelector('meta[name=csrf-token]');
    this.csrfToken = csrfMeta ? csrfMeta.content : '';

    const contentEl = container.querySelector('[data-behavior~=content-textile]');

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
    bootstrap.Offcanvas.getOrCreateInstance(this.panel).show();
  }

  closePanel() {
    bootstrap.Offcanvas.getInstance(this.panel)?.hide();
  }

  // -- Thread display (via Turbo Frame) ------------------------------------

  showThread(threadId) {
    this.frame.src = `${this.basePath}/${threadId}`;
    this.openPanel();
  }

  showNewThreadForm(anchor) {
    this.frame.innerHTML = this.buildNewThreadForm(anchor);
    this.openPanel();

    const textarea = this.frame.querySelector('textarea');
    if (textarea) textarea.focus();
  }

  // -- Data fetching and highlighting --------------------------------------

  fetchAndHighlight() {
    fetch(this.threadsPath, {
      headers: { 'Accept': 'application/json' }
    })
      .then(r => r.json())
      .then(threads => {
        this.highlighter.highlight(threads);
      });
  }

  // -- Events --------------------------------------------------------------

  bindEvents() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.panel.classList.contains('show')) {
        this.closePanel();
      }
    });

    // Clear frame when offcanvas finishes hiding (covers dismiss button, Escape, and programmatic close).
    this.panel.addEventListener('hidden.bs.offcanvas', () => {
      this.frame.innerHTML = '';
    });

    // Liquid async rendering replaces innerHTML of content-textile,
    // destroying all <mark> highlights. Re-fetch and re-highlight.
    $(this.container).find('[data-behavior~=content-textile]').on(
      'dradis:liquid-rendered', () => {
        this.fetchAndHighlight();
      }
    );

    // After any Turbo form submission in our panel, re-highlight threads.
    // Turbo Streams have already updated the panel DOM by this point.
    document.addEventListener('turbo:submit-end', (e) => {
      if (!e.target.closest('[data-behavior~=inline-thread-panel]')) return;
      if (!e.detail.success) return;

      this.fetchAndHighlight();

      // Close panel if the thread was deleted (frame is now empty)
      setTimeout(() => {
        if (this.frame && !this.frame.querySelector('[data-behavior~=inline-thread]')) {
          this.closePanel();
        }
      }, 100);
    });
  }

  // -- Helpers -------------------------------------------------------------

  buildNewThreadForm(anchor) {
    return `<div class="p-3">
      <h6>New Comment Thread</h6>
      <blockquote class="thread-quoted-text border-start border-3 border-primary ps-3 text-muted fst-italic">
        ${this.escapeHtml(anchor.exact)}
      </blockquote>
      <form action="${this.basePath}" method="post" accept-charset="UTF-8" data-turbo="true">
        <input type="hidden" name="authenticity_token" value="${this.csrfToken}">
        ${this.buildAnchorFields(anchor)}
        <div class="mb-2">
          <textarea name="comment[content]" class="form-control form-control-sm"
            placeholder="Add a comment..." rows="3" required></textarea>
        </div>
        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-sm btn-primary">Create Thread</button>
        </div>
      </form>
    </div>`;
  }

  buildAnchorFields(anchor) {
    const prefix = 'inline_comment_thread[anchor]';

    return `<input type="hidden" name="${prefix}[type]" value="${this.escapeHtml(anchor.type)}">
      <input type="hidden" name="${prefix}[exact]" value="${this.escapeHtml(anchor.exact)}">
      <input type="hidden" name="${prefix}[prefix]" value="${this.escapeHtml(anchor.prefix)}">
      <input type="hidden" name="${prefix}[suffix]" value="${this.escapeHtml(anchor.suffix)}">
      <input type="hidden" name="${prefix}[field_name]" value="${this.escapeHtml(anchor.field_name || '')}">
      <input type="hidden" name="${prefix}[position][start]" value="${anchor.position.start}">
      <input type="hidden" name="${prefix}[position][end]" value="${anchor.position.end}">`;
  }

  escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }
}
