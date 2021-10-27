/*

To initialize:

new QuoteSelector(EditorToolbar);

Where `content` is an element of [data-behavior=content-textile]
*/

class QuoteSelector {
  constructor(content) {
    this.$content = $(content);

    // Only ever assign a single quote selector to a container
    if (this.$content.data('quoteSelector') !== undefined) { return; }

    // Only assign a quote selector if we have a rich text editor to quote too
    if ($('[data-behavior~=rich-toolbar]').length === 0) { return; }

    this.init();
  }

  init() {
    this.$quoteBtn = $('\
      <div class="selection-quote-button d-none" data-behavior="selection-quote-button" aria-label="quote text">\
          <i class="fa fa-quote-left fa-fw mr-1"></i>\
          <span>Quote Text</span>\
      </div>');
    this.$content.append(this.$quoteBtn);

    this.$content.data('quoteSelector', this);

    this.behaviors();
  }

  behaviors() {
    var that = this;

    // Keep track of what editor box was last used
    // Instances where multiple editors may be present is when someone
    // is editing a previous comment. There will be two comment editors.
    // Use the only editor we can find if there's only one.
    this.lastActiveEditor = $('[data-behavior~=rich-toolbar]').data('editorToolbar');
    $('[data-behavior~=rich-toolbar]').on('focus', function() {
      that.lastActiveEditor = $(this).data('editorToolbar');
    });

    // Get the selected text positions so we can place the quote box above it
    $(document).on('mouseup', function(e) {
      var selectionObj = document.getSelection();
      // Only show the quote button if there is a selection and it starts and
      // ends within a content-textile container
      if (!(selectionObj.isCollapsed) &&
        ($(selectionObj.anchorNode).parents("[data-behavior=content-textile]").length == 1) &&
        ($(selectionObj.focusNode).parents("[data-behavior=content-textile]").length == 1)) {
        var selectionPosition = selectionObj.getRangeAt(0).getBoundingClientRect(),
            parentPosition = that.$content[0].getBoundingClientRect(),
            boundingBoxX = selectionPosition.x - parentPosition.x,
            boundingBoxY = selectionPosition.y - parentPosition.y,
            chevronOffsetY = 8, // Psuedo element downward chevron under quote button
            chevronOffsetX = 15, // Psuedo element downward chevron left offset from button left side
            clonedRange = selectionObj.getRangeAt(0).cloneRange();

        // Clone the range and collapse it so we can take measurement of only
        // the first line. We make a clone because calling `collapse` will
        // unselect the content the user has highlighted if we call it on the
        // original element.
        clonedRange.collapse(true);
        var firstLineOffset = clonedRange.getBoundingClientRect().x - parentPosition.x;

        that.$quoteBtn
          .removeClass('d-none')
          .css({
            'top': boundingBoxY - (that.$quoteBtn.outerHeight() + chevronOffsetY),
            'left': firstLineOffset - chevronOffsetX
          });
      }
    })

    // Clear the quote box and selection
    $(document).on('mousedown', function(e) {
      if ($(e.target).parent().is('[data-behavior~=selection-quote-button]')) {
        // no-op;
        // Was a click on the quote button itself
      } else {
        that.clear();
      }
    })

    this.$quoteBtn.on('click', function() {
      var editor = that.lastActiveEditor,
          selectionText = document.getSelection().toString(),
          affix = editor.affixesLibrary('quote', selectionText);

      editor.injectSyntax(affix);
      that.clear();
    })
  }

  clear() {
    this.$quoteBtn.addClass('d-none');

    if (document.getSelection().empty) {  // Chrome
      document.getSelection().empty();
    } else if (document.getSelection().removeAllRanges) {  // Firefox
      document.getSelection().removeAllRanges();
    }
  }
}
