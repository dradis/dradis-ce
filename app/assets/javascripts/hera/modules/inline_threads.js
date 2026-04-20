const fuzzyIndexOf = (text, selection) => {
  const parts = selection.split(/\s+/).map(
    part => part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  );
  if (parts.length < 2) return null;

  const pattern = new RegExp(parts.join('\\s+'));
  const match = text.match(pattern);
  if (!match) return null;

  return { start: match.index, end: match.index + match[0].length };
};

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
      } catch (error) {
        console.warn('Could not highlight segment for thread ' + thread.id + ':', error.message);
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

  // Each segment stays within a single text node so surroundContents works safely.
  // Uses innerText because anchor.exact comes from getSelection().toString(),
  // which mirrors innerText behavior (inserting \n at block boundaries and <br> elements).
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

    const nodeMap = [];
    let searchFrom = 0;

    for (let i = 0; i < textNodes.length; i++) {
      const content = textNodes[i].textContent;
      if (!content.trim()) continue;

      const pos = combined.indexOf(content, searchFrom);
      if (pos === -1) continue;

      nodeMap.push({ node: textNodes[i], startIndex: pos, endIndex: pos + content.length });
      searchFrom = pos + content.length;
    }

    const segments = [];

    for (let j = 0; j < nodeMap.length; j++) {
      const entry = nodeMap[j];
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

    // Use event delegation on $content rather than direct binding on the button.
    // jQuery's .html() (used by liquid_async.js) calls cleanData() on child elements,
    // stripping directly-bound handlers. Delegated handlers survive on the parent.
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

class InlineThreadTurbo {
  constructor(container) {
    this.container = container;
    this.threadsPath = container.dataset.inlineThreadsPath;
    this.basePath = container.dataset.inlineThreadsBasePath;
    this.commentableType = container.dataset.commentableType;
    this.commentableId = container.dataset.commentableId;

    this.panel = document.querySelector('[data-behavior~=inline-thread-panel]');
    this.frame = document.querySelector('[data-behavior~=inline-thread-content]');

    const contentEl = container.querySelector('[data-behavior~=content-textile]');

    // Prevent QuoteSelector from binding to this content-textile element.
    $(contentEl).data('quoteSelector', 'inline-thread');

    this.highlighter = new InlineThreadHighlighter(contentEl, this);
    this.selector = new InlineThreadSelector(container, this);

    this.bindEvents();
    this.fetchAndHighlight();
  }

  openPanel() { bootstrap.Offcanvas.getOrCreateInstance(this.panel).show(); }
  closePanel() { bootstrap.Offcanvas.getInstance(this.panel)?.hide(); }

  showThread(threadId) {
    this.frame.src = `${this.basePath}/${threadId}`;
    this.openPanel();
  }

  showNewThreadForm(anchor) {
    const params = new URLSearchParams({
      'inline_thread[commentable_type]': this.commentableType,
      'inline_thread[commentable_id]':   this.commentableId,
      'inline_thread[anchor]':           JSON.stringify(anchor)
    });
    this.frame.src = `${this.basePath}/new?${params}`;
    this.openPanel();
  }

  fetchAndHighlight() {
    fetch(this.threadsPath, { headers: { 'Accept': 'application/json' } })
      .then(response => response.json())
      .then(threads => this.highlighter.highlight(threads));
  }

  bindEvents() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.panel.classList.contains('show')) this.closePanel();
    });

    // Covers dismiss button, Escape key, and programmatic close.
    this.panel.addEventListener('hidden.bs.offcanvas', () => {
      this.frame.innerHTML = '';
    });

    // Liquid async rendering replaces innerHTML of content-textile, destroying highlights.
    $(this.container).find('[data-behavior~=content-textile]').on(
      'dradis:liquid-rendered', () => this.fetchAndHighlight()
    );

    // Close before the Turbo response arrives so the panel animates away cleanly.
    document.addEventListener('turbo:submit-start', (e) => {
      if (e.target.matches('[data-behavior~=delete-thread-form]')) this.closePanel();
    });

    document.addEventListener('turbo:submit-end', (e) => {
      if (!e.target.closest('[data-behavior~=inline-thread-panel]')) return;

      if (e.detail.success) {
        this.fetchAndHighlight();
      } else {
        this.showError(e.target);
      }
    });

    this.panel.addEventListener('input', (e) => {
      if (e.target.matches('textarea')) this.clearErrors();
    });
  }

  showError(form) {
    form.querySelector('[data-behavior~=inline-thread-error]').classList.remove('d-none');
  }

  clearErrors() {
    this.frame.querySelectorAll('[data-behavior~=inline-thread-error]').forEach(el => el.classList.add('d-none'));
  }

}
