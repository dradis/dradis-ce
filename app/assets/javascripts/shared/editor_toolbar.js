/* 

To initialize:

new EditorToolbar($element);

Where `$element` is a jQuery object that has a child input (with type = text) or textarea element.
Note: Multiple $elements can be stacked: new EditorToolbar($element, $anotherElement, $nthElement);

Each of these input and/or textarea elements will have the Editor Toolbar added.

*/

class EditorToolbar {
  constructor($target) {
    this.$target = $target;
    this.affixes = this.affixesLibrary();
    this.init();
  }

  init() {
    // find all child input text and textarea elements
    this.$target.find('input[type="text"], textarea').each(function() {
      // wrap each element in a div and add toolbar element as sibling
      $(this).wrap('<div class="editor-field" data-behavior="editor-field"></div>');
      $(this).parent().append('<div class="editor-toolbar" data-behavior="editor-toolbar"></div>');
    });

    // create toolbar buttons for each toolbar
    var that = this;
    $('[data-behavior~=editor-toolbar]').each(function() {
      if ($(this).prev('textarea').length) { // toolbar for textarea elements
        $(this).append(that.textareaElements());
      } else if ($(this).prev('input[type=text]').length) { // toolbar for input type=text elements
        $(this).append(that.inputTextElements());
      }
    });

    this.behaviors();
  }

  behaviors() {
    var that = this;

    // enabling/disabling specific toolbar functions for textareas on selection
    $('[data-behavior~=editor-field] textarea').on('click change keyup select', function() {   
      if (window.getSelection().toString().length > 0 || this.selectionStart != this.selectionEnd) { // when there is text selected
        $(this).parent().find('[data-btn~=table]').addClass('disabled');
      }
      else { // when there is no text selected
        $(this).parent().find('[data-btn~=table]').removeClass('disabled');
      }
    });

    // when a toolbar button is clicked
    $('[data-btn]').click(function () {
      var $element = $(this).parents('[data-behavior~=editor-field]').children('textarea, input[type=text]');
      var affix = that.affixes[$(this).data('btn')]
  
      // inject markdown
      that.injectMarkdown($element, affix.prefix, affix.suffix, affix.placeholder);
    });

    // keyboard shortcuts
    document.onkeydown = function(e) {
      var key = e.which || e.keyCode; // for cross-browser compatibility
      if (e.metaKey && key === 66 ) { // 66 = b
        e.preventDefault();
        $('[data-btn~=bold]').click();
      }
      else if (e.metaKey && key === 73 ) { // 73 = i
        e.preventDefault();
        $('[data-btn~=italic]').click();
      }
      else if (e.metaKey && key === 75 ) { // 75 = k
        e.preventDefault();
        $('[data-btn~=link]').click();
      }
    };
  }

  injectMarkdown($element, prefix, suffix, placeholder) {
    var adjustedPrefixLength = prefix.length, adjustedSuffixLength = suffix.length;
    var startIndex = $element[0].selectionStart, endIndex = $element[0].selectionEnd;
    var elementText = $element.val(), selectedText = $element.val().substring(startIndex, endIndex).split('\n');
    var markdownText = '';

    // create string to inject with markdown added
    selectedText.map(function(selection, index) {
      if (selection == '') { // no text was selected, add markdown to placeholder text
        markdownText = prefix + placeholder + suffix;
      }
      else { // text selected, add markdown to each line of selected text
        markdownText += prefix + selection + suffix;
        
        // if not the last line of selection, add new line and account for prefix/suffix length injected on that line
        if (index < selectedText.length - 1) {
          markdownText += '\n';
          adjustedPrefixLength += prefix.length;
          adjustedSuffixLength += suffix.length;
        }
      }
    });

    // remove the original selection (if there was one) and add new markdown string in it's place
    $element.focus(); // bring focus back to $element from the toolbar
    if (navigator.userAgent.toLowerCase().indexOf('firefox') > -1) { // firefox
      $element.val(elementText.slice(0, startIndex) + markdownText + elementText.slice(endIndex));
    }
    else { // all other browsers
      document.execCommand('insertText', false, markdownText);
    }
    
    // post-injection cursor location
    if (startIndex == endIndex) { // no text was selected, select injected placeholder text
      $element[0].setSelectionRange(startIndex + prefix.length, startIndex + markdownText.length - suffix.length);
    }
    else { // text was selected, place cursor after the injected string
      $element[0].setSelectionRange(adjustedPrefixLength + endIndex + adjustedSuffixLength, adjustedPrefixLength + endIndex + adjustedSuffixLength);
    }

    $element.trigger('textchange');
  }

  affixesLibrary() {
    return {
      'block-code':  new Affix({'prefix': 'bc. ', 'placeholder': 'Code markup' }),
      'bold':        new Affix({'prefix': '*',    'placeholder': 'Bold text',         'suffix': '*' }),
      'header':      new Affix({'prefix': '#[',   'placeholder': 'Header text',       'suffix': ']#' }),
      'highlight':   new Affix({'prefix': '$${{', 'placeholder': 'Highlighted text',  'suffix': '}}$$' }),
      'inline-code': new Affix({'prefix': '@',    'placeholder': 'Inline code',       'suffix': '@' }),
      'italic':      new Affix({'prefix': '_',    'placeholder': 'Italic text',       'suffix': '_' }),
      'link':        new Affix({'prefix': '"',    'suffix': '":http://' }),
      'list-ol':     new Affix({'prefix': '# ',   'placeholder': 'Ordered item' }),
      'list-ul':     new Affix({'prefix': '* ',   'placeholder': 'Unordered item' }),
      'quote':       new Affix({'prefix': 'bq. ', 'placeholder': 'Quoted text' }),
      'table':       new Affix({'placeholder': '|_. Col 1 Header|_. Col 2 Header|\n|Col 1 Row 1|Col 2 Row 1|\n|Col 1 Row 2|Col 2 Row 2|' })
    }
  }

  textareaElements() {
    return '<div class="editor-btn" data-btn="header" aria-label="header text">\
      <i class="fa fa-header"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="bold" aria-label="bold text">\
      <i class="fa fa-bold"></i>\
    </div>\
    <div class="editor-btn px-2" data-btn="italic" aria-label="italic text">\
      <i class="fa fa-italic"></i>\
    </div>\
    <div class="editor-btn" data-btn="highlight" aria-label="highlighted text">\
      <i class="fa fa-paint-brush"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="quote" aria-label="quote block">\
      <i class="fa fa-quote-left"></i>\
    </div>\
    <div class="editor-btn" data-btn="link" aria-label="link">\
      <i class="fa fa-link"></i>\
    </div>\
    <div class="editor-btn" data-btn="table" aria-label="table">\
      <i class="fa fa-table"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="block-code" aria-label="code block">\
      <i class="fa fa-code"></i>\
    </div>\
    <div class="editor-btn" data-btn="inline-code" aria-label="inline code">\
      <i class="fa fa-terminal"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="list-ul" aria-label="unordered list">\
      <i class="fa fa-list-ul"></i>\
    </div>\
    <div class="editor-btn" data-btn="list-ol" aria-label="ordered list">\
      <i class="fa fa-list-ol"></i>\
    </div>'
  }

  inputTextElements() {
    return '<div class="editor-btn" data-btn="bold" aria-label="bold text">\
      <i class="fa fa-bold"></i>\
    </div>\
    <div class="editor-btn px-2" data-btn="italic" aria-label="italic text">\
      <i class="fa fa-italic"></i>\
    </div>\
    <div class="editor-btn" data-btn="highlight" aria-label="highlighted text">\
      <i class="fa fa-paint-brush"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="link" aria-label="link">\
      <i class="fa fa-link"></i>\
    </div>\
    <div class="editor-btn" data-btn="inline-code" aria-label="inline code">\
      <i class="fa fa-terminal"></i>\
    </div>'
  }
}

/*
 * A helper class to return blank strings when values don't exist
 */
class Affix {
  constructor(opts) {
    this.opts = opts
  }

  get prefix() {
    return this.opts.prefix || ''
  }

  get placeholder() {
    return this.opts.placeholder || ''
  }

  get suffix() {
    return this.opts.suffix || ''
  }
}
