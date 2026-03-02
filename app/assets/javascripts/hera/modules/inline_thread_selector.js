/*
  InlineThreadSelector

  Handles text selection within the QA issue body and shows
  an "Add Comment" popover button. On click, opens the
  InlineThreadPanel with the built anchor data.

  Follows the QuoteSelector pattern (see quote_selector.js).

  Usage:
    new InlineThreadSelector(containerElement, panel);

  Where `containerElement` is the [data-behavior=inline-threads-container]
  wrapper and `panel` is an InlineThreadPanel instance.
*/

class InlineThreadSelector {
  constructor(container, panel) {
    this.$container = $(container);
    this.$content = this.$container.find('[data-behavior~=content-textile]');
    this.panel = panel;
    this.rawText = this.$content.data('content') || '';
    this.createPath = this.$container.data('inline-threads-create-path');
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
        // Capture the selected text NOW while it still exists.
        // The browser may clear the selection on mousedown when the
        // user clicks the "Add Comment" button.
        that.pendingSelection = selectionObj.toString();

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
        that.pendingSelection = null;
      }
    });

    // Use event delegation on $content rather than direct binding on the
    // button element. jQuery's .html() (used by liquid_async.js) calls
    // cleanData() on child elements, stripping any directly-bound handlers.
    // Delegated handlers survive because they live on the parent.
    this.$content.on('click', '[data-behavior~=inline-comment-button]', function () {
      var selectedText = that.pendingSelection;
      if (!selectedText) return;

      var anchor = that.buildAnchor(selectedText);
      if (anchor) {
        that.panel.openNewThread(anchor, that.createPath);
      }

      that.pendingSelection = null;
      that.clearSelection();
      that.clearButton();
    });
  }

  // Build a version of the raw text with #[Field]# markers replaced by just
  // the field name, plus a position map from stripped→raw indices. This lets
  // us find user selections (which see rendered text without markers) and
  // map back to raw text positions for anchoring.
  _buildFieldMap() {
    var raw = this.rawText.replace(/\r\n/g, '\n');
    this._normalizedRaw = raw;
    this._strippedText = '';
    this._strippedToRaw = [];

    var fieldRegex = /#\[([^\]]*?)\]#/g;
    var lastEnd = 0;
    var match;

    while ((match = fieldRegex.exec(raw)) !== null) {
      // Copy characters before the marker as-is
      for (var i = lastEnd; i < match.index; i++) {
        this._strippedToRaw.push(i);
        this._strippedText += raw.charAt(i);
      }
      // Copy just the field name (skip #[ and ]#)
      var nameStart = match.index + 2;
      var name = match[1];
      for (var j = 0; j < name.length; j++) {
        this._strippedToRaw.push(nameStart + j);
        this._strippedText += name.charAt(j);
      }
      lastEnd = match.index + match[0].length;
    }

    // Copy remaining text after last marker
    for (var k = lastEnd; k < raw.length; k++) {
      this._strippedToRaw.push(k);
      this._strippedText += raw.charAt(k);
    }
  }

  buildAnchor(selectedText) {
    var selection = selectedText.replace(/\r\n/g, '\n');
    var raw = this._normalizedRaw;

    // Fast path: exact match in raw text (selection within a single field value)
    var rawIndex = raw.indexOf(selection);
    if (rawIndex === -1) {
      rawIndex = raw.indexOf(selection.trim());
      if (rawIndex !== -1) { selection = selection.trim(); }
    }

    if (rawIndex !== -1) {
      return this._buildResult(rawIndex, rawIndex + selection.length, selectedText);
    }

    // Slow path: search in stripped text (handles selections spanning #[Field]#)
    var strippedIndex = this._strippedText.indexOf(selection);
    if (strippedIndex === -1) {
      var trimmed = selection.trim();
      strippedIndex = this._strippedText.indexOf(trimmed);
      if (strippedIndex !== -1) { selection = trimmed; }
    }

    if (strippedIndex === -1) {
      return null;
    }

    // Map stripped positions back to raw positions
    var rawStart = this._strippedToRaw[strippedIndex];
    var endMapIndex = strippedIndex + selection.length - 1;
    if (endMapIndex >= this._strippedToRaw.length) {
      return null;
    }
    var rawEnd = this._strippedToRaw[endMapIndex] + 1;

    return this._buildResult(rawStart, rawEnd, selectedText);
  }

  _buildResult(rawStart, rawEnd, selectedText) {
    var raw = this._normalizedRaw;

    var prefixStart = Math.max(0, rawStart - 30);
    var prefix = raw.substring(prefixStart, rawStart);
    var suffixEnd = Math.min(raw.length, rawEnd + 30);
    var suffix = raw.substring(rawEnd, suffixEnd);
    var fieldName = this.findFieldName(rawStart);

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
    var fieldRegex = /#\[(.+?)\]#/g;
    var match;
    var currentField = null;
    var raw = this._normalizedRaw;

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
