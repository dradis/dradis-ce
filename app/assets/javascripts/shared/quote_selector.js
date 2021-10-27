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

    // Keep track of what editor box was last used, and where the cursor was so
    // that we can inject the quote into the right editor, at the right
    // location. Instances where multiple editors may be present is when someone
    // is editing a previous comment. There will be two comment editors.
    // Use the only editor we can find if there's only one.
    this.lastActiveEditor = $('[data-behavior~=rich-toolbar]').data('editorToolbar');
    $('[data-behavior~=rich-toolbar]').on('focus', function() {
      that.lastActiveEditor = $(this).data('editorToolbar');
    });

    // Get the selected text positions so we can place the quote box above it
    this.$content.on('mouseup', function(e) {
      var selectionObj = document.getSelection();

      if (selectionObj.toString().trim().length > 0) {
        var selectionPosition = selectionObj.getRangeAt(0).getBoundingClientRect(),
            parentPosition = that.$content[0].getBoundingClientRect(),
            x = selectionPosition.x - parentPosition.x,
            y = selectionPosition.y - parentPosition.y;

        that.$quoteBtn
          .removeClass('d-none')
          .css({'top': y - (that.$quoteBtn.outerHeight() + 8), 'left': x - 15});
      }
    })

    // Clear the quote box and selection
    $(document).on('mousedown', function(e) {
      if ($(e.target).parent().is('[data-behavior~=selection-quote-button]')) {
        // no-op;
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
