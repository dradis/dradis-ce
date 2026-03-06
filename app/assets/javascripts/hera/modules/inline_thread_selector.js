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
    this.renderedText = this.$content[0].innerText;
    this.pendingSelection = null;

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

  buildAnchor(selectedText) {
    const text = this.renderedText;

    let index = text.indexOf(selectedText);
    if (index === -1) {
      selectedText = selectedText.trim();
      index = text.indexOf(selectedText);
    }

    if (index === -1) return null;

    const prefixStart = Math.max(0, index - 30);
    const prefix = text.substring(prefixStart, index);
    const endPos = index + selectedText.length;
    const suffixEnd = Math.min(text.length, endPos + 30);
    const suffix = text.substring(endPos, suffixEnd);
    const fieldName = this.findFieldName(index);

    return {
      type: 'TextQuoteSelector',
      exact: selectedText,
      prefix: prefix,
      suffix: suffix,
      position: {
        start: index,
        end: endPos
      },
      field_name: fieldName
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
