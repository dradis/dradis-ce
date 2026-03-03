/*
  InlineThreadSelector

  Handles text selection within the QA issue body and shows
  an "Add Comment" popover button. On click, builds a new thread
  form and injects it into the Turbo Frame panel.

  Follows the QuoteSelector pattern (see quote_selector.js).

  Usage:
    new InlineThreadSelector(containerElement, coordinator);

  Where `containerElement` is the [data-behavior=inline-threads-container]
  wrapper and `coordinator` is an InlineThreadTurbo instance.
*/

class InlineThreadSelector {
  constructor(container, coordinator) {
    this.$container = $(container);
    this.$content = this.$container.find('[data-behavior~=content-textile]');
    this.coordinator = coordinator;
    this.rawText = this.$content.data('content') || '';
    this.pendingSelection = null;

    this._buildFieldMap();

    // Prevent double-binding
    if (this.$container.data('inlineThreadSelector')) {
      return;
    }
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
    // destroying our appended button. Re-append after render completes.
    this.$content.on('dradis:liquid-rendered', () => {
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

      if (this.isValidSelection(selectionObj)) {
        // Capture the selected text NOW while it still exists.
        // The browser may clear the selection on mousedown when the
        // user clicks the "Add Comment" button.
        this.pendingSelection = selectionObj.toString();

        const range = selectionObj.getRangeAt(0);
        const selectionPosition = range.getBoundingClientRect();
        const parentPosition = this.$content[0].getBoundingClientRect();
        const boundingBoxY = selectionPosition.y - parentPosition.y;
        const chevronOffsetY = 8;
        const chevronOffsetX = 15;

        const clonedRange = range.cloneRange();
        clonedRange.collapse(true);
        const boundingBoxX = clonedRange.getBoundingClientRect().x - parentPosition.x;

        this.$commentBtn.removeClass('d-none').css({
          top: boundingBoxY - (this.$commentBtn.outerHeight() + chevronOffsetY),
          left: boundingBoxX - chevronOffsetX
        });
      }
    });

    $(document).on('mousedown.inlineThread', (e) => {
      if (!$(e.target).closest('[data-behavior~=inline-comment-button]').length &&
          !e.shiftKey) {
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
      if (anchor) {
        this.coordinator.showNewThreadForm(anchor);
      }

      this.pendingSelection = null;
      this.clearSelection();
      this.clearButton();
    });
  }

  // Build a version of the raw text with #[Field]# markers replaced by just
  // the field name, plus a position map from stripped→raw indices. This lets
  // us find user selections (which see rendered text without markers) and
  // map back to raw text positions for anchoring.
  _buildFieldMap() {
    const raw = this.rawText.replace(/\r\n/g, '\n');
    this._normalizedRaw = raw;
    this._strippedText = '';
    this._strippedToRaw = [];

    const fieldRegex = /#\[([^\]]*?)\]#/g;
    let lastEnd = 0;
    let match;

    while ((match = fieldRegex.exec(raw)) !== null) {
      // Copy characters before the marker as-is
      for (let i = lastEnd; i < match.index; i++) {
        this._strippedToRaw.push(i);
        this._strippedText += raw.charAt(i);
      }
      // Copy just the field name (skip #[ and ]#)
      const nameStart = match.index + 2;
      const name = match[1];
      for (let j = 0; j < name.length; j++) {
        this._strippedToRaw.push(nameStart + j);
        this._strippedText += name.charAt(j);
      }
      lastEnd = match.index + match[0].length;
    }

    // Copy remaining text after last marker
    for (let k = lastEnd; k < raw.length; k++) {
      this._strippedToRaw.push(k);
      this._strippedText += raw.charAt(k);
    }
  }

  buildAnchor(selectedText) {
    let selection = selectedText.replace(/\r\n/g, '\n');
    const raw = this._normalizedRaw;

    // Fast path: exact match in raw text (selection within a single field value)
    let rawIndex = raw.indexOf(selection);
    if (rawIndex === -1) {
      rawIndex = raw.indexOf(selection.trim());
      if (rawIndex !== -1) { selection = selection.trim(); }
    }

    if (rawIndex !== -1) {
      return this._buildResult(rawIndex, rawIndex + selection.length, selectedText);
    }

    // Slow path: search in stripped text (handles selections spanning #[Field]#)
    let strippedIndex = this._strippedText.indexOf(selection);
    if (strippedIndex === -1) {
      const trimmed = selection.trim();
      strippedIndex = this._strippedText.indexOf(trimmed);
      if (strippedIndex !== -1) { selection = trimmed; }
    }

    if (strippedIndex === -1) {
      return null;
    }

    // Map stripped positions back to raw positions
    const rawStart = this._strippedToRaw[strippedIndex];
    const endMapIndex = strippedIndex + selection.length - 1;
    if (endMapIndex >= this._strippedToRaw.length) {
      return null;
    }
    const rawEnd = this._strippedToRaw[endMapIndex] + 1;

    return this._buildResult(rawStart, rawEnd, selectedText);
  }

  _buildResult(rawStart, rawEnd, selectedText) {
    const raw = this._normalizedRaw;

    const prefixStart = Math.max(0, rawStart - 30);
    const prefix = raw.substring(prefixStart, rawStart);
    const suffixEnd = Math.min(raw.length, rawEnd + 30);
    const suffix = raw.substring(rawEnd, suffixEnd);
    const fieldName = this.findFieldName(rawStart);

    return {
      type: 'TextQuoteSelector',
      exact: selectedText,
      prefix: prefix,
      suffix: suffix,
      position: {
        start: rawStart,
        end: rawEnd
      },
      field_name: fieldName
    };
  }

  findFieldName(position) {
    const fieldRegex = /#\[(.+?)\]#/g;
    let match;
    let currentField = null;
    const raw = this._normalizedRaw;

    while ((match = fieldRegex.exec(raw)) !== null) {
      if (match.index > position) {
        break;
      }
      currentField = match[1];
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

  clearButton() {
    this.$commentBtn.addClass('d-none');
  }

  clearSelection() {
    if (document.getSelection().empty) {
      document.getSelection().empty();
    } else if (document.getSelection().removeAllRanges) {
      document.getSelection().removeAllRanges();
    }
  }
}
