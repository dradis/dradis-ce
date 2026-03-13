// Inline comment threads — text selection, highlighting, and Turbo coordination.
//
// Entry point: new InlineThreadTurbo(container) (see pages/qa.js)

// Find `needle` in `haystack` allowing whitespace runs in the needle
// to match any whitespace run in the haystack. Returns { start, end }
// positions in the original haystack, or null.
const fuzzyIndexOf = (haystack, needle) => {
  const parts = needle.split(/\s+/).map(
    s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  );
  if (parts.length < 2) return null;

  const pattern = new RegExp(parts.join('\\s+'));
  const match = haystack.match(pattern);
  if (!match) return null;

  return { start: match.index, end: match.index + match[0].length };
};

// -- InlineThreadHighlighter -------------------------------------------------
//
// Renders <mark> highlights on the rendered HTML content for existing inline
// comment threads. Uses TreeWalker to find matching text nodes and wraps them.

class InlineThreadHighlighter {
  constructor(contentElement, coordinator) {
    this.contentEl = contentElement;
    this.coordinator = coordinator;
  }

  highlight(threads) {
    this.clearHighlights();
    threads.forEach(thread => this.highlightThread(thread));
  }

  highlightThread(thread) {
    const exact = thread.anchor.exact;
    if (!exact) return;

    const segments = this.findTextInNodes(this.getTextNodes(), exact);
    if (segments.length === 0) return;

    const marks = this.wrapSegments(segments, thread);
    marks.forEach(mark => {
      mark.addEventListener('click', (e) => {
        e.preventDefault();
        this.coordinator.showThread(thread.id);
      });
    });
  }

  // Wrap each matched text node segment with a <mark> element.
  // Processes in reverse order to avoid invalidating DOM offsets.
  wrapSegments(segments, thread) {
    const marks = [];

    for (let i = segments.length - 1; i >= 0; i--) {
      const seg = segments[i];

      try {
        const range = document.createRange();
        range.setStart(seg.node, seg.startOffset);
        range.setEnd(seg.node, seg.endOffset);

        const mark = document.createElement('mark');
        mark.className = 'inline-thread-highlight';
        mark.dataset.behavior = 'inline-thread-highlight';
        mark.dataset.threadId = thread.id;
        mark.dataset.commentCount = thread.comments.length;

        if (thread.status === 'resolved') mark.classList.add('resolved');
        if (thread.outdated) mark.classList.add('outdated');

        range.surroundContents(mark);
        marks.push(mark);
      } catch (e) {
        console.warn('Could not highlight segment for thread ' + thread.id + ':', e.message);
      }
    }

    return marks;
  }

  clearHighlights() {
    const marks = this.contentEl.querySelectorAll('[data-behavior~=inline-thread-highlight]');
    marks.forEach(mark => {
      const parent = mark.parentNode;
      while (mark.firstChild) parent.insertBefore(mark.firstChild, mark);
      parent.removeChild(mark);
      parent.normalize();
    });
  }

  getTextNodes() {
    const textNodes = [];
    const walker = document.createTreeWalker(
      this.contentEl,
      NodeFilter.SHOW_TEXT,
      null,
      false
    );

    let node;
    while ((node = walker.nextNode())) textNodes.push(node);

    return textNodes;
  }

  // Returns an array of { node, startOffset, endOffset } segments —
  // one per text node that overlaps the match. Each segment stays
  // within a single text node so surroundContents works safely.
  //
  // Uses innerText as the combined string because anchor.exact comes
  // from getSelection().toString() which mirrors innerText behavior
  // (inserting \n at block boundaries and <br> elements).
  findTextInNodes(textNodes, searchText) {
    const combined = this.contentEl.innerText;
    let matchIndex = combined.indexOf(searchText);
    let matchEnd;

    if (matchIndex !== -1) {
      matchEnd = matchIndex + searchText.length;
    } else {
      // Cross-browser: anchor.exact may use different whitespace than
      // the current browser's innerText. Fuzzy-match whitespace.
      const result = fuzzyIndexOf(combined, searchText);
      if (!result) return [];
      matchIndex = result.start;
      matchEnd = result.end;
    }

    // Map each text node to its position within innerText
    const nodeMap = [];
    let searchFrom = 0;

    for (var i = 0; i < textNodes.length; i++) {
      var content = textNodes[i].textContent;
      if (!content.trim()) continue;

      var pos = combined.indexOf(content, searchFrom);
      if (pos === -1) continue;

      nodeMap.push({ node: textNodes[i], startIndex: pos, endIndex: pos + content.length });
      searchFrom = pos + content.length;
    }

    const segments = [];

    for (var j = 0; j < nodeMap.length; j++) {
      var entry = nodeMap[j];
      if (entry.endIndex <= matchIndex) continue;
      if (entry.startIndex >= matchEnd) break;

      segments.push({
        node: entry.node,
        startOffset: Math.max(matchIndex, entry.startIndex) - entry.startIndex,
        endOffset: Math.min(matchEnd, entry.endIndex) - entry.startIndex
      });
    }

    return segments;
  }
}

// -- InlineThreadSelector ----------------------------------------------------
//
// Handles text selection within the QA issue body and shows an "Add Comment"
// popover button. On click, builds a new thread form via the coordinator.

class InlineThreadSelector {
  constructor(container, coordinator) {
    this.$container = $(container);
    this.$content = this.$container.find('[data-behavior~=content-textile]');
    this.coordinator = coordinator;
    this.renderedText = this.$content[0].innerText;
    this.pendingSelection = null;

    // Prevent double-binding
    if (this.$container.data('inlineThreadSelector')) return;
    this.$container.data('inlineThreadSelector', this);

    this.init();
  }

  init() {
    this.$commentBtn = $(
      '<div class="inline-comment-button d-none" data-behavior="inline-comment-button">' +
        '<i class="fa-solid fa-comment fa-fw me-1"></i>' +
        '<span>Add Comment</span>' +
      '</div>'
    );

    this.appendButton();
    this.bindEvents();

    // Liquid async rendering replaces innerHTML of content-textile,
    // destroying our appended button. Re-read text and re-append.
    this.$content.on('dradis:liquid-rendered', () => {
      this.renderedText = this.$content[0].innerText;
      this.appendButton();
    });
  }

  appendButton() {
    this.$content.append(this.$commentBtn);
    this.$content.css('position', 'relative');
  }

  bindEvents() {
    $(document).on('mouseup.inlineThread', () => {
      const selectionObj = document.getSelection();
      if (!this.isValidSelection(selectionObj)) return;

      // Capture the selected text NOW while it still exists.
      // The browser may clear the selection on mousedown when the
      // user clicks the "Add Comment" button.
      this.pendingSelection = selectionObj.toString();

      const range = selectionObj.getRangeAt(0);
      const selectionPosition = range.getBoundingClientRect();
      const parentPosition = this.$content[0].getBoundingClientRect();

      const clonedRange = range.cloneRange();
      clonedRange.collapse(true);

      this.$commentBtn.removeClass('d-none').css({
        top: selectionPosition.y - parentPosition.y - (this.$commentBtn.outerHeight() + 8),
        left: clonedRange.getBoundingClientRect().x - parentPosition.x - 15
      });
    });

    $(document).on('mousedown.inlineThread', (e) => {
      if (!$(e.target).closest('[data-behavior~=inline-comment-button]').length && !e.shiftKey) {
        this.clearButton();
        this.pendingSelection = null;
      }
    });

    // Use event delegation on $content rather than direct binding on the
    // button element. jQuery's .html() (used by liquid_async.js) calls
    // cleanData() on child elements, stripping any directly-bound handlers.
    // Delegated handlers survive because they live on the parent.
    this.$content.on('click', '[data-behavior~=inline-comment-button]', () => {
      const selectedText = this.pendingSelection;
      if (!selectedText) return;

      const anchor = this.buildAnchor(selectedText);
      if (anchor) this.coordinator.showNewThreadForm(anchor);

      this.pendingSelection = null;
      this.clearSelection();
      this.clearButton();
    });
  }

  buildAnchor(selectedText) {
    const text = this.renderedText;
    let index = text.indexOf(selectedText);

    if (index === -1) {
      selectedText = selectedText.trim();
      index = text.indexOf(selectedText);
    }

    // Cross-field selections span block elements (e.g. <h5> headings).
    // Browsers differ in how Selection.toString() whitespace-separates
    // blocks vs how innerText does it. Normalise whitespace to find the match.
    if (index === -1) {
      const result = fuzzyIndexOf(text, selectedText);
      if (result) {
        index = result.start;
        selectedText = text.substring(result.start, result.end);
      }
    }

    if (index === -1) return null;

    const endPos = index + selectedText.length;

    return {
      type: 'TextQuoteSelector',
      exact: selectedText,
      prefix: text.substring(Math.max(0, index - 30), index),
      suffix: text.substring(endPos, Math.min(text.length, endPos + 30)),
      position: { start: index, end: endPos },
      field_name: this.findFieldName(index)
    };
  }

  findFieldName(position) {
    const text = this.renderedText;
    const headings = this.$content[0].querySelectorAll('h5');
    let currentField = null;

    for (let i = 0; i < headings.length; i++) {
      const name = headings[i].textContent.trim();
      const headingPos = text.indexOf(name);
      if (headingPos === -1 || headingPos > position) break;
      currentField = name;
    }

    return currentField;
  }

  isValidSelection(selectionObj) {
    if (selectionObj.isCollapsed) return false;

    const anchorParent = $(selectionObj.anchorNode).closest('[data-behavior~=content-textile]');
    const focusParent = $(selectionObj.focusNode).closest('[data-behavior~=content-textile]');

    return anchorParent.length === 1 &&
           focusParent.length === 1 &&
           anchorParent.is(this.$content);
  }

  clearButton() { this.$commentBtn.addClass('d-none'); }

  clearSelection() {
    if (document.getSelection().empty) {
      document.getSelection().empty();
    } else if (document.getSelection().removeAllRanges) {
      document.getSelection().removeAllRanges();
    }
  }
}

// -- InlineThreadTurbo -------------------------------------------------------
//
// Coordinator: wires InlineThreadHighlighter and InlineThreadSelector together
// using Turbo Frames and Turbo Streams for server-rendered responses.
//
// - Existing threads load into the panel via Turbo Frame (GET show)
// - New thread forms are built client-side and submitted via Turbo (POST create)
// - Resolve/reopen/reply are server-rendered inside the Turbo Frame

class InlineThreadTurbo {
  constructor(container) {
    this.container = container;
    this.threadsPath = container.dataset.inlineThreadsPath;
    this.basePath = container.dataset.inlineThreadsBasePath;
    this.commentableType = container.dataset.commentableType;
    this.commentableId = container.dataset.commentableId;

    this.panel = document.querySelector('[data-behavior~=inline-thread-panel]');
    this.frame = document.querySelector('[data-behavior~=inline-thread-content]');

    const csrfMeta = document.querySelector('meta[name=csrf-token]');
    this.csrfToken = csrfMeta ? csrfMeta.content : '';

    const contentEl = container.querySelector('[data-behavior~=content-textile]');

    // Prevent QuoteSelector from binding to this content-textile element.
    $(contentEl).data('quoteSelector', 'inline-thread');

    this.highlighter = new InlineThreadHighlighter(contentEl, this);
    this.selector = new InlineThreadSelector(container, this);

    this.bindEvents();
    this.fetchAndHighlight();
  }

  // -- Panel management ------------------------------------------------------

  openPanel() { bootstrap.Offcanvas.getOrCreateInstance(this.panel).show(); }
  closePanel() { bootstrap.Offcanvas.getInstance(this.panel)?.hide(); }

  // -- Thread display (via Turbo Frame) --------------------------------------

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

  // -- Data fetching and highlighting ----------------------------------------

  fetchAndHighlight() {
    fetch(this.threadsPath, { headers: { 'Accept': 'application/json' } })
      .then(r => r.json())
      .then(threads => this.highlighter.highlight(threads));
  }

  // -- Events ----------------------------------------------------------------

  bindEvents() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.panel.classList.contains('show')) this.closePanel();
    });

    // Clear frame when offcanvas hides (covers dismiss button, Escape, and programmatic close).
    this.panel.addEventListener('hidden.bs.offcanvas', () => {
      this.frame.innerHTML = '';
    });

    // Liquid async rendering replaces innerHTML of content-textile,
    // destroying all <mark> highlights. Re-fetch and re-highlight.
    $(this.container).find('[data-behavior~=content-textile]').on(
      'dradis:liquid-rendered', () => this.fetchAndHighlight()
    );

    // Close the panel as soon as a delete is submitted so the user doesn't
    // see the frame empty out before the panel animates away.
    document.addEventListener('turbo:submit-start', (e) => {
      if (e.target.matches('[data-behavior~=delete-thread-form]')) this.closePanel();
    });

    // After any Turbo form submission in our panel, re-highlight or show error.
    document.addEventListener('turbo:submit-end', (e) => {
      if (!e.target.closest('[data-behavior~=inline-thread-panel]')) return;

      if (e.detail.success) {
        this.clearErrors();
        this.fetchAndHighlight();
      } else {
        this.showError(e.target);
      }
    });

    this.panel.addEventListener('input', (e) => {
      if (e.target.matches('textarea')) this.clearErrors();
    });
  }

  // -- Error feedback --------------------------------------------------------

  showError(form) {
    this.clearErrors();
    const alert = document.createElement('div');
    alert.className = 'alert alert-danger py-1 px-2 mb-2 small';
    alert.dataset.behavior = 'inline-thread-error';
    alert.textContent = 'Something went wrong. Please try again.';
    form.prepend(alert);
  }

  clearErrors() {
    this.frame.querySelectorAll('[data-behavior~=inline-thread-error]').forEach(el => el.remove());
  }

  // -- Form building ---------------------------------------------------------

  buildNewThreadForm(anchor) {
    const fragment = document.createDocumentFragment();

    const blockquote = document.createElement('blockquote');
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

    this.buildCommentableFields().forEach(el => form.appendChild(el));
    this.buildAnchorFields(anchor).forEach(el => form.appendChild(el));

    const textareaWrapper = document.createElement('div');
    textareaWrapper.className = 'mb-2';
    const textarea = document.createElement('textarea');
    textarea.name = 'inline_thread[comments_attributes][0][content]';
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

  buildCommentableFields() {
    const prefix = 'inline_thread';

    return [
      [prefix + '[commentable_type]', this.commentableType],
      [prefix + '[commentable_id]',   this.commentableId]
    ].map(([name, value]) => {
      const input = document.createElement('input');
      input.type = 'hidden';
      input.name = name;
      input.value = value;
      return input;
    });
  }

  buildAnchorFields(anchor) {
    const prefix = 'inline_thread[anchor]';

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
