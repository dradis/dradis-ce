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
    this.frame.innerHTML = '';
    this.frame.appendChild(this.buildNewThreadForm(anchor));
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

    // Close the panel as soon as the delete form is submitted (after confirm),
    // so the user doesn't see the frame empty out before the panel animates away.
    document.addEventListener('turbo:submit-start', (e) => {
      if (!e.target.matches('[data-behavior~=delete-thread-form]')) return;
      this.closePanel();
    });

    // After any Turbo form submission in our panel, re-highlight threads.
    document.addEventListener('turbo:submit-end', (e) => {
      if (!e.target.closest('[data-behavior~=inline-thread-panel]')) return;
      if (!e.detail.success) return;

      this.fetchAndHighlight();
    });
  }

  // -- Helpers -------------------------------------------------------------

  buildNewThreadForm(anchor) {
    const fragment = document.createDocumentFragment();

    const blockquote = document.createElement('blockquote');
    blockquote.className = 'thread-quoted-text border-start border-3 border-primary ps-3 text-muted fst-italic';
    blockquote.textContent = anchor.exact;
    fragment.appendChild(blockquote);

    const form = document.createElement('form');
    form.action = this.basePath;
    form.method = 'post';
    form.acceptCharset = 'UTF-8';
    form.dataset.turbo = 'true';

    const csrfInput = document.createElement('input');
    csrfInput.type = 'hidden';
    csrfInput.name = 'authenticity_token';
    csrfInput.value = this.csrfToken;
    form.appendChild(csrfInput);

    this.buildAnchorFields(anchor).forEach(el => form.appendChild(el));

    const textareaWrapper = document.createElement('div');
    textareaWrapper.className = 'mb-2';
    const textarea = document.createElement('textarea');
    textarea.name = 'comment[content]';
    textarea.className = 'form-control form-control-sm';
    textarea.placeholder = 'Add a comment...';
    textarea.rows = 3;
    textarea.required = true;
    textareaWrapper.appendChild(textarea);
    form.appendChild(textareaWrapper);

    const buttonWrapper = document.createElement('div');
    buttonWrapper.className = 'd-flex gap-2';
    const button = document.createElement('button');
    button.type = 'submit';
    button.className = 'btn btn-sm btn-primary';
    button.textContent = 'Create Thread';
    buttonWrapper.appendChild(button);
    form.appendChild(buttonWrapper);

    fragment.appendChild(form);

    return fragment;
  }

  buildAnchorFields(anchor) {
    const prefix = 'inline_comment_thread[anchor]';

    return [
      [prefix + '[type]',            anchor.type],
      [prefix + '[exact]',           anchor.exact],
      [prefix + '[prefix]',          anchor.prefix],
      [prefix + '[suffix]',          anchor.suffix],
      [prefix + '[field_name]',      anchor.field_name || ''],
      [prefix + '[position][start]', anchor.position.start],
      [prefix + '[position][end]',   anchor.position.end]
    ].map(([name, value]) => {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = name;
      input.value = value;
      return input;
    });
  }
}
