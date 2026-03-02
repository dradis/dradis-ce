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
    var that = this;
    this.$content.on('dradis:liquid-rendered', function () {
      that.appendButton();
    });
  }

  appendButton() {
    this.$content.append(this.$commentBtn);
    this.$content.css('position', 'relative');
  }

  bindEvents() {
    var that = this;

    $(document).on('mouseup.inlineThread', function () {
      var selectionObj = document.getSelection();

      if (that.isValidSelection(selectionObj)) {
        var range = selectionObj.getRangeAt(0);
        var selectionPosition = range.getBoundingClientRect();
        var parentPosition = that.$content[0].getBoundingClientRect();
        var boundingBoxY = selectionPosition.y - parentPosition.y;
        var chevronOffsetY = 8;
        var chevronOffsetX = 15;

        var clonedRange = range.cloneRange();
        clonedRange.collapse(true);
        var boundingBoxX = clonedRange.getBoundingClientRect().x - parentPosition.x;

        that.$commentBtn.removeClass('d-none').css({
          top: boundingBoxY - (that.$commentBtn.outerHeight() + chevronOffsetY),
          left: boundingBoxX - chevronOffsetX
        });
      }
    });

    $(document).on('mousedown.inlineThread', function (e) {
      if (!$(e.target).closest('[data-behavior~=inline-comment-button]').length &&
          !e.shiftKey) {
        that.clearButton();
      }
    });

    this.$commentBtn.on('click', function () {
      var selectedText = document.getSelection().toString();
      if (!selectedText) return;

      var anchor = that.buildAnchor(selectedText);
      if (anchor) {
        that.coordinator.showNewThreadForm(anchor);
      }

      that.clearSelection();
      that.clearButton();
    });
  }

  buildAnchor(selectedText) {
    // Find the selected text in the raw content
    var index = this.rawText.indexOf(selectedText);
    if (index === -1) {
      var normalizedRaw = this.rawText.replace(/\r\n/g, '\n');
      var normalizedSelection = selectedText.replace(/\r\n/g, '\n');
      index = normalizedRaw.indexOf(normalizedSelection);

      if (index === -1) {
        var trimmed = selectedText.trim();
        index = normalizedRaw.indexOf(trimmed);
        if (index !== -1) {
          selectedText = trimmed;
        }
      }
    }

    if (index === -1) {
      return null;
    }

    var prefixStart = Math.max(0, index - 30);
    var prefix = this.rawText.substring(prefixStart, index);
    var suffixEnd = Math.min(this.rawText.length, index + selectedText.length + 30);
    var suffix = this.rawText.substring(index + selectedText.length, suffixEnd);
    var fieldName = this.findFieldName(index);

    return {
      type: 'TextQuoteSelector',
      exact: selectedText,
      prefix: prefix,
      suffix: suffix,
      position: {
        start: index,
        end: index + selectedText.length
      },
      field_name: fieldName
    };
  }

  findFieldName(position) {
    var fieldRegex = /#\[(.+?)\]#/g;
    var match;
    var currentField = null;

    while ((match = fieldRegex.exec(this.rawText)) !== null) {
      if (match.index > position) {
        break;
      }
      currentField = match[1];
    }

    return currentField;
  }

  isValidSelection(selectionObj) {
    if (selectionObj.isCollapsed) return false;

    var anchorParent = $(selectionObj.anchorNode).closest('[data-behavior~=content-textile]');
    var focusParent = $(selectionObj.focusNode).closest('[data-behavior~=content-textile]');

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
