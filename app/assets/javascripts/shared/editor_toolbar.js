/* 

To initialize:

new EditorToolbar($element);

Where `$element` is a jQuery object that is an input (with type = text) or textarea element.

Each of these input and/or textarea elements will have the Editor Toolbar added.

*/

class EditorToolbar {
  constructor($target) {
    if (!$target.is("textarea")) { console.log("Can't initialize a rich toolbar on anything but a textarea"); return; }

    this.$target = $target;
    this.opts = { 'include': $target.data('rich-toolbar').split(' ') };
    this.affixes = this.affixesLibrary();
    this.init();
  }

  init() {
    this.$target.wrap('<div class="editor-field" data-behavior="editor-field"><div class="textarea-container"></div></div>');
    this.$editorField = this.$target.parents('[data-behavior=editor-field]');
    this.$editorField.prepend('<div class="editor-toolbar" data-behavior="editor-toolbar"></div>');
    this.$editorToolbar = this.$editorField.find('[data-behavior=editor-toolbar]');

    this.$editorToolbar.append(this.textareaElements(this.opts.include));

    this.behaviors();
  }

  behaviors() {
    var that = this;

    this.$target.on('click change keyup select', function() {
      // enabling/disabling specific toolbar functions for textareas on selection
      if (window.getSelection().toString().length > 0 || this.selectionStart != this.selectionEnd) { // when there is text selected
        that.$editorField.find('[data-btn~=table]').addClass('disabled');
      } else { // when there is no text selected
        that.$editorField.find('[data-btn~=table]').removeClass('disabled');
      }
    });

    // Handler for setting the correct textarea height on keyboard input
    this.$target[0].addEventListener('input', setHeight);

    function setHeight(e) {
      const shrinkEvents = ['deleteContentForward', 'deleteContentBackward', 'deleteByCut', 'historyUndo', 'historyRedo'];

      if (shrinkEvents.includes(e.inputType)) {
        // shrink the text area when content is being removed
        $(this).css({'height': '1px'});
      }
      
      // expand the textarea to fix the content
      $(this).css({'height': this.scrollHeight + 2});
    };
  
    // Handler for setting the correct textarea heights on load (for current values)
    this.$target.each(setHeight);

    // Handler for setting the correct textarea height when focus is lost
    this.$target.on('blur', setHeight);

    // when a toolbar button is clicked
    this.$editorToolbar.find('[data-btn]').click(function () {
      var $element = that.$editorField.find('textarea, input[type=text]');
      var affix = that.affixes[$(this).data('btn')];
  
      // inject markdown
      that.injectSyntax($element, affix);
    });

    // keyboard shortcuts
    this.$editorField.find('textarea, input[type=text]').keydown(function(e) {
      var key = e.which || e.keyCode; // for cross-browser compatibility

      if (e.metaKey && key === 66 ) { // 66 = b
        e.preventDefault();
        that.$editorToolbar.find('[data-btn~=bold]').click();
      }
      else if (e.metaKey && key === 73 ) { // 73 = i
        e.preventDefault();
        that.$editorToolbar.find('[data-btn~=italic]').click();
      }
      else if (e.metaKey && key === 75 ) { // 75 = k
        e.preventDefault();
        that.$editorToolbar.find('[data-btn~=link]').click();
      }
    });

    // toolbar sticky positioning
    $('[data-behavior~=editor-field]').find('textarea').on('focus', function() {
      var $inputElement = $(this),
          $toolbarElement = $inputElement.parent().prev(),
          $parentElement = $inputElement.parents('[data-behavior~=editor-field]'),
          topOffset;
      
      $toolbarElement.css({'opacity': 1, 'visibility': 'visible'});

      // set offset to 0 if user is in fullscreen mode.
      if ($inputElement.parents('.textile-fullscreen').length ? topOffset = 0 : topOffset = 60);

      // this is needed incase user sets focus on textarea where toolbar would render off screen
      if ($inputElement.height() > 40 && $parentElement.offset().top < $(window).scrollTop() + topOffset) {
        $parentElement.addClass('sticky-toolbar');
      }

      // adjust position on scroll to make toolbar always appear at the top of the textarea
      document.querySelector('[data-behavior~=view-content], .textile-fullscreen').addEventListener('scroll', (function () {
        var parentOffsetTop = $parentElement.offset().top - topOffset;

        // keep toolbar at the top of text area when scrolling
        if ($inputElement.height() > 40 && parentOffsetTop < $(window).scrollTop()) {
          $parentElement.addClass('sticky-toolbar');
        }
        else {
          // reset the toolbar to the default position and appearance
          $parentElement.removeClass('sticky-toolbar');
        }
      }));
    });

    // reset position and hide toolbar once focus is lost
    $('[data-behavior~=editor-field]').find('textarea').on('blur', function() {
      $(this).parent().prev().css({'opacity': 0, 'visibility': 'hidden'});
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
      'field':       new Affix('#[', 'Field', ']#\n'),
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

  textareaElements(include) {
    var str = '';

    if (include.includes('field')) str += '<div class="editor-btn" data-btn="field" aria-label="add new field">\
      <i class="fa fa-plus"></i>\
    </div>\
    <div class="divider-vertical"></div>';

    if (include.includes('bold')) str += '<div class="editor-btn" data-btn="bold" aria-label="bold text">\
      <i class="fa fa-bold"></i>\
    </div>';

    if (include.includes('italic')) str += '<div class="editor-btn px-2" data-btn="italic" aria-label="italic text">\
      <i class="fa fa-italic"></i>\
    </div>';

    str += '<div class="divider-vertical"></div>';

    if (include.includes('block-code')) str += '<div class="editor-btn" data-btn="block-code" aria-label="code block">\
      <i class="fa fa-code"></i>\
    </div>';

    if (include.includes('link')) str += '<div class="editor-btn" data-btn="link" aria-label="link">\
      <i class="fa fa-link"></i>\
    </div>';
    if (include.includes('table')) str += '<div class="editor-btn" data-btn="table" aria-label="table">\
      <i class="fa fa-table"></i>\
    </div>';

    str += '<div class="divider-vertical"></div>';

    if (include.includes('list-ul')) str += '<div class="editor-btn" data-btn="list-ul" aria-label="unordered list">\
      <i class="fa fa-list-ul"></i>\
    </div>';
    if (include.includes('list-ol')) str += '<div class="editor-btn" data-btn="list-ol" aria-label="ordered list">\
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
    return str;
  }

  /*
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
  */
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
