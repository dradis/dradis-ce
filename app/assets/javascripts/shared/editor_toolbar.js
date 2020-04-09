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

    $('[data-behavior~=editor-field] textarea').on('click change keyup select', function() {   
      // enabling/disabling specific toolbar functions for textareas on selection
      if (window.getSelection().toString().length > 0 || this.selectionStart != this.selectionEnd) { // when there is text selected
        $(this).parent().find('[data-btn~=table]').addClass('disabled');
      }
      else { // when there is no text selected
        $(this).parent().find('[data-btn~=table]').removeClass('disabled');
      }

      // remove field button in comments
      if ($(this).parents().is('[data-behavior~=comment-feed]')) {
        $(this).parent().find('[data-btn~=field]').next().remove();
        $(this).parent().find('[data-btn~=field]').remove();
      }
    });

    // when a toolbar button is clicked
    $('[data-btn]').click(function () {
      var $element = $(this).parents('[data-behavior~=editor-field]').children('textarea, input[type=text]');
      var affix = that.affixes[$(this).data('btn')];
  
      // inject markdown
      that.injectSyntax($element, affix);
    });

    // keyboard shortcuts
    $('[data-behavior~=editor-field]').children('textarea, input[type=text]').keydown(function(e) {
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
    });

    // toolbar sticky positioning
    $('[data-behavior~=editor-field]').children('textarea').on('focus', function() {
      var $inputElement = $(this),
          $toolbarElement = $inputElement.next(),
          $parentElement = $inputElement.parent();

      // this is needed incase user sets focus on textarea where toolbar would render off screen
      if ($parentElement.offset().top < $(window).scrollTop() + 60) {
        $parentElement.addClass('sticky-toolbar');
        $toolbarElement.css({'top': parseInt(60 - $parentElement.offset().top)});
      }

      // adjust position on scroll to make toolbar always appear at the top of the textarea
      document.querySelector('[data-behavior~=view-content]').addEventListener('scroll', (function stickyToolbar() {
        var $parentOffset = $parentElement.offset().top;
        if ($parentOffset < $(window).scrollTop() + 60) {
          $parentElement.addClass('sticky-toolbar');
          $toolbarElement.css({'top': parseInt(60 - $parentOffset)});
        }
        else {
          $parentElement.removeClass('sticky-toolbar');
          $toolbarElement.css({'top': '-3.4rem'});
        }
      }));
    });
  }

  injectSyntax($element, affix) {
    var adjustedPrefixLength = affix.prefix.length,
        adjustedSuffixLength = affix.suffix.length,
        startIndex = $element[0].selectionStart,
        endIndex = $element[0].selectionEnd,
        elementText = $element.val(),
        selectedText = $element.val().substring(startIndex, endIndex);

    var markdownText = (startIndex == endIndex) ? affix.asPlaceholder : affix.withSelection(selectedText);

    adjustedPrefixLength *= selectedText.split('\n').length;
    adjustedSuffixLength *= selectedText.split('\n').length;

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
      $element[0].setSelectionRange(startIndex + affix.prefix.length, startIndex + markdownText.length - affix.suffix.length);
    }
    else { // text was selected, place cursor after the injected string
      $element[0].setSelectionRange(adjustedPrefixLength + endIndex + adjustedSuffixLength, adjustedPrefixLength + endIndex + adjustedSuffixLength);
    }

    // Trigger a change event because javascript manipulation doesn't trigger
    // them. The change event will reload the preview
    $element.trigger('textchange');
  }

  affixesLibrary() {
    return {
      'block-code':  new BlockAffix('bc. ', 'Code markup'),
      'bold':        new Affix('*', 'Bold text', '*'),
      'field':      new Affix('#[', 'Field', ']#\n'),
      //'highlight':   new Affix('$${{', 'Highlighted text', '}}$$'),
      //'inline-code': new Affix('@', 'Inline code', '@'),
      'italic':      new Affix('_', 'Italic text', '_'),
      'link':        new Affix('"', 'Link text', '":http://'),
      'list-ol':     new Affix('# ', 'Ordered item'),
      'list-ul':     new Affix('* ', 'Unordered item'),
      //'quote':       new BlockAffix('bq. ', 'Quoted text'),
      'table':       new Affix('', '|_. Col 1 Header|_. Col 2 Header|\n|Col 1 Row 1|Col 2 Row 1|\n|Col 1 Row 2|Col 2 Row 2|')
    };
  }

  textareaElements() {
    return '<div class="editor-btn" data-btn="field" aria-label="add new field">\
      <i class="fa fa-plus"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="bold" aria-label="bold text">\
      <i class="fa fa-bold"></i>\
    </div>\
    <div class="editor-btn px-2" data-btn="italic" aria-label="italic text">\
      <i class="fa fa-italic"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="block-code" aria-label="code block">\
      <i class="fa fa-code"></i>\
    </div>\
    <div class="editor-btn" data-btn="link" aria-label="link">\
      <i class="fa fa-link"></i>\
    </div>\
    <div class="editor-btn" data-btn="table" aria-label="table">\
      <i class="fa fa-table"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="list-ul" aria-label="unordered list">\
      <i class="fa fa-list-ul"></i>\
    </div>\
    <div class="editor-btn" data-btn="list-ol" aria-label="ordered list">\
      <i class="fa fa-list-ol"></i>\
    </div>';

    /* Additional buttons for future use

    <div class="editor-btn" data-btn="highlight" aria-label="highlighted text">\
      <i class="fa fa-paint-brush"></i>\
    </div>\
    <div class="editor-btn" data-btn="inline-code" aria-label="inline code">\
      <i class="fa fa-terminal"></i>\
    </div>\ 
    <div class="editor-btn" data-btn="quote" aria-label="quote block">\
      <i class="fa fa-quote-left"></i>\
    </div>\

    */
  }

  inputTextElements() {
    return '<div class="editor-btn" data-btn="bold" aria-label="bold text">\
      <i class="fa fa-bold"></i>\
    </div>\
    <div class="editor-btn px-2" data-btn="italic" aria-label="italic text">\
      <i class="fa fa-italic"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="link" aria-label="link">\
      <i class="fa fa-link"></i>\
    </div>';
  }
}

/*
 * A helper class to return blank strings when values don't exist
 */
class Affix {
  constructor(prefix = '', placeholder = '', suffix = '') {
    this.prefix = prefix;
    this.placeholder = placeholder;
    this.suffix = suffix;
  }

  get asPlaceholder() {
    return this.prefix + this.placeholder + this.suffix;
  }

  wrapped(selection) {
    return this.prefix + selection + this.suffix;
  }

  withSelection(selectedText) {
    var lines = selectedText.split('\n');

    lines = lines.reduce(function(text, selection, index) {
      return (index == 0 ? this.wrapped(selection) : text + '\n' + this.wrapped(selection));
    }.bind(this), '');

    // Account for accidental empty line selections before/after a group
    var wordSplit = selectedText.split(' '),
        first = wordSplit[0],
        last = wordSplit[selectedText.length-1];
    if (first == '\n') lines.unshift(first);
    if (last == '\n') lines.push(last);

    return lines;
  }
}

class BlockAffix extends Affix {
  withSelection(selectedText) {
    return this.prefix + selectedText;
  }
}
