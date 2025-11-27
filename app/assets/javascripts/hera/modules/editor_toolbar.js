/*

To initialize:

new EditorToolbar($target);

Where `$target` is a jQuery object that is an input (with type = text) or textarea element.

Each of these input and/or textarea elements will have the Editor Toolbar added.

*/

class EditorToolbar {
  constructor($target) {
    if (!$target.is('textarea')) {
      console.log("Can't initialize a rich toolbar on anything but a textarea");
      return;
    }

    this.$target = $target;
    this.opts = {
      include: $target.data('rich-toolbar').split(' '),
      uploader: $target.data('rich-toolbar-uploader'),
    };

    if (
      this.opts.include.includes('image') &&
      this.opts.uploader === undefined
    ) {
      console.log(
        'You initialized a RichToolbar with the image uploader option but have not provided an existing uploader to utilize'
      );
      return;
    }

    this.init();
  }

  init() {
    this.$target.wrap(
      '<div class="editor-field" data-behavior="editor-field"><div class="textarea-container"></div></div>'
    );
    this.$editorField = this.$target.parents('[data-behavior~=editor-field]');
    this.$editorField.prepend(
      '<div class="editor-toolbar" data-behavior="editor-toolbar"></div>'
    );
    this.$editorToolbar = this.$editorField.find(
      '[data-behavior~=editor-toolbar]'
    );

    this.$editorToolbar.append(this.textareaElements(this.opts.include));

    this.$target.data('editorToolbar', this);

    if (this.opts.include.includes('image')) {
      this.addUploader();
    }

    this.behaviors();
  }

  addUploader() {
    var that = this;
    this.$fileField = $(
      '<input type="file" name="editor-toolbar-' +
        Math.random().toString(36) +
        '[]" multiple accept="image/*" style="display: none">'
    );
    this.$editorToolbar.append(this.$fileField);

    this.$fileField.bind('change', function (e) {
      $(that.opts.uploader).fileupload('add', {
        files: this.files,
        $textarea: that.$target,
      });

      // Clear the $fileField so it never submit unexpected filedata
      $(this).val('');
    });
  }

  behaviors() {
    var that = this;

    this.$target.on('click change keyup select', function () {
      that.updateSelectionButtons();
      that.updateCodeBlockButtons();
    });

    // Handler for setting the correct textarea height on keyboard input, on focus,
    // when focus is lost, or when content is inserted programmatically
    this.$target.on('blur focus textchange input', this.setHeight);

    // Handler for setting the correct textarea heights on load (for current values)
    this.$target.each(this.setHeight);

    // when a toolbar button is clicked
    this.$editorToolbar.find('[data-btn]').click(function () {
      if ($(this).is('[data-btn~=image')) {
        that.$fileField.click();
      } else {
        var cursorInfo = that.$target.cursorInfo(),
          affix = that.affixesLibrary($(this).data('btn'), cursorInfo.text);

        that.injectSyntax(affix);
      }
    });

    // keyboard shortcuts
    this.$target.keydown(function (e) {
      var key = e.which || e.keyCode, // for cross-browser compatibility
        selector;

      if (e.metaKey || e.ctrlKey) {
        switch (key) {
          case 66:
            selector = '[data-btn~=bold]';
            break; // 66 = b
          case 73:
            selector = '[data-btn~=italic]';
            break; // 73 = i
          case 75:
            selector = '[data-btn~=link]';
            break; // 75 = k
        }

        if (selector !== undefined) {
          e.preventDefault();
          that.$editorToolbar.find(selector).click();
        }
      }
    });

    // toolbar sticky positioning
    this.$target.on('focus', function () {
      const $inputElement = $(this),
        $toolbarElement = $inputElement.parent().prev(),
        $editorField = $inputElement.parents('[data-behavior~=editor-field]'),
        inputMinHeightForStickyToolbar = 40,
        headerHeight = $('header').outerHeight();

      $toolbarElement.css({ opacity: 1, visibility: 'visible' });

      // this is needed in case user sets focus on textarea where toolbar would render off screen
      if (
        $inputElement.height() > inputMinHeightForStickyToolbar &&
        $editorField.offset().top < $(window).scrollTop() + headerHeight
      ) {
        $editorField.addClass('sticky-toolbar');
      }

      // adjust position on scroll to make toolbar always appear at the top of the textarea
      $(window).on('scroll.editor-toolbar', function () {
        const parentOffsetTop = $editorField.offset().top;

        // keep toolbar at the top of text area when scrolling
        if (
          $inputElement.height() > inputMinHeightForStickyToolbar &&
          parentOffsetTop < $(window).scrollTop() + headerHeight
        ) {
          $editorField.addClass('sticky-toolbar');
        } else {
          // reset the toolbar to the default position and appearance
          $editorField.removeClass('sticky-toolbar');
        }
      });
    });

    // reset position and hide toolbar once focus is lost
    this.$target.on('blur', function () {
      const $toolbarElement = $(this).parent().prev();

      $toolbarElement.css({ opacity: 0, visibility: 'hidden' });
    });
  }

  updateSelectionButtons() {
    const noSelectionButtons = '[data-btn~=table], [data-btn~=image]';
    const textarea = this.$target[0];

    if (
      window.getSelection().toString().length > 0 ||
      textarea.selectionStart != textarea.selectionEnd
    ) {
      // when there is text selected
      this.$editorField.find(noSelectionButtons).addClass('disabled');
    } else {
      // when there is no text selected
      this.$editorField.find(noSelectionButtons).removeClass('disabled');
    }
  }

  updateCodeBlockButtons() {
    const codeBlockButtons = '[data-btn~=highlight]';
    const $buttons = this.$editorField.find(codeBlockButtons);
    const cursorInfo = this.$target.cursorInfo();
    const lines = this.$target.val().split('\n');
    const newlineLength = 1;
    const blockLevelPattern = /^(bc\.\.?|bq\.\.?|p\.|#|\*)/;
    let charCount = 0;
    let currentlyInBlock = false;
    let isMultilineBlock = false;

    for (const line of lines) {
      const lineStart = charCount;
      const lineEnd = charCount + line.length;

      // detect start of code block
      if (line.match(/^bc\.\./)) {
        currentlyInBlock = true;
        isMultilineBlock = true;
      } else if (line.match(/^bc\./)) {
        currentlyInBlock = true;
        isMultilineBlock = false;
      } else if (currentlyInBlock) {
        // detect end of code block
        if (
          isMultilineBlock ? line.match(blockLevelPattern) : line.trim() === ''
        ) {
          currentlyInBlock = false;
          isMultilineBlock = false;
        }
      }

      if (
        currentlyInBlock &&
        cursorInfo.start >= lineStart &&
        cursorInfo.start <= lineEnd + newlineLength
      ) {
        $buttons.removeClass('disabled');
        return;
      }

      charCount += line.length + newlineLength;
    }

    $buttons.addClass('disabled');
  }

  setHeight(e) {
    const shrinkEvents = [
      'deleteContentForward',
      'deleteContentBackward',
      'deleteByCut',
      'historyUndo',
      'historyRedo',
    ];

    if (
      e.originalEvent !== undefined &&
      shrinkEvents.includes(e.originalEvent.inputType)
    ) {
      // shrink the text area when content is being removed
      $(this).css({ height: '1px' });
    }

    // expand the textarea to fix the content
    $(this).css({ height: this.scrollHeight + 2 });
  }

  // Splices the content where it needs to go in the textarea
  // vs injectSyntax() which takes an Affix and manages pre/post cursor positioning
  insert(text) {
    var cursorInfo = this.$target.cursorInfo(),
      elementText = this.$target.val();

    this.$target.val(
      elementText.slice(0, cursorInfo.start) +
        text +
        elementText.slice(cursorInfo.end)
    );
  }

  setCursor(affix, cursorInfo) {
    var adjustedPrefixLength =
        affix.prefix.length * affix.selection.split('\n').length,
      adjustedSuffixLength =
        affix.suffix.length * affix.selection.split('\n').length;

    // post-injection cursor location
    if (cursorInfo.hasSelection()) {
      // text was selected, place cursor after the injected string
      var position =
        adjustedPrefixLength + cursorInfo.end + adjustedSuffixLength;
      this.$target[0].setSelectionRange(position, position);
    } else {
      // no text was selected, select injected placeholder text
      this.$target[0].setSelectionRange(
        cursorInfo.start + affix.prefix.length,
        cursorInfo.start + affix.asString().length - affix.suffix.length
      );
    }
  }

  // Takes an affix. Uses the insert function to splice content. Highlights
  // content or places cursor at the end of new content.
  // Triggers the textchange event for rendering and local cache updating.
  injectSyntax(affix) {
    this.$target.focus(); // bring focus back to $target from the toolbar
    var cursorInfo = this.$target.cursorInfo(); // Save the original position

    this.insert(affix.asString());
    this.setCursor(affix, cursorInfo);

    // Trigger a change event because javascript manipulation doesn't
    this.$target.trigger('textchange');
  }

  insertImagePlaceholder(index, file) {
    var affix = this.affixesLibrary('image-placeholder', file.name);
    this.insert(affix.asString());

    var position =
      this.$target.val().indexOf(affix.asString()) + affix.asString().length;

    this.$target.focus();
    this.$target[0].setSelectionRange(position, position);
  }

  replaceImagePlaceholder(data, index, file) {
    var placeholder = this.affixesLibrary('image-placeholder', file.name),
      affix = this.affixesLibrary('image', data.result[0].url);

    this.$target.val(
      this.$target
        .val()
        .replace(placeholder.asString(), affix.asString(), this.$target)
    );

    var position = this.$target.val().indexOf(affix.asString()),
      cursorInfo = new CursorInfo(position, position, undefined);

    this.setCursor(affix, cursorInfo);
    this.$target.trigger('textchange');
  }

  affixesLibrary(type, selection) {
    const library = {
      'block-code': new BlockAffix('\nbc.', 'Code markup'),
      bold: new Affix('*', 'Bold text', '*'),
      field: new Affix('#[', 'Field', ']#\n'),
      highlight: new Affix('$${{', 'Highlighted code', '}}$$'),
      image: new Affix('\n!', 'https://', '!\n'),
      'image-placeholder': new Affix('\n!', 'https://', ' uploading...!\n'),
      'inline-code': new Affix('@', 'Inline code', '@'),
      italic: new Affix('_', 'Italic text', '_'),
      link: new Affix('"', 'Link text', '":https://'),
      'list-ol': new Affix('# ', 'Ordered item'),
      'list-ul': new Affix('* ', 'Unordered item'),
      quote: new BlockAffix('\nbq.', 'Quoted text'),
      table: new Affix(
        '',
        '|_. Col 1 Header|_. Col 2 Header|\n|Col 1 Row 1|Col 2 Row 1|\n|Col 1 Row 2|Col 2 Row 2|'
      ),
    };

    return Object.create(library[type], { selection: { value: selection } });
  }

  textareaElements(include) {
    var str = '';

    if (include.includes('field'))
      str +=
        '<div class="editor-btn" data-btn="field" aria-tooltip="add new field">\
          <i class="fa-solid fa-plus"></i>\
        </div>\
        <div class="divider-vertical"></div>';

    if (include.includes('bold'))
      str +=
        '<div class="editor-btn" data-btn="bold" aria-tooltip="bold text">\
          <i class="fa-solid fa-bold"></i>\
        </div>';

    if (include.includes('italic'))
      str +=
        '<div class="editor-btn px-2" data-btn="italic" aria-tooltip="italic text">\
          <i class="fa-solid fa-italic"></i>\
        </div>';

    str += '<div class="divider-vertical"></div>';

    if (include.includes('inline-code'))
      str +=
        '<div class="editor-btn" data-btn="inline-code" aria-tooltip="inline code">\
          <i class="fa-solid fa-code"></i>\
        </div>';

    if (include.includes('block-code'))
      str +=
        '<div class="editor-btn" data-btn="block-code" aria-tooltip="code block">\
          <span class="fa-stack">\
            <i class="fa-regular fa-square fa-stack-2x"></i>\
            <i class="fa-solid fa-code fa-stack-1x"></i>\
          </span>\
        </div>';

    if (include.includes('highlight'))
      str +=
        '<div class="editor-btn px-2" data-btn="highlight" aria-tooltip="highlight code">\
          <i class="fa-solid fa-highlighter"></i>\
        </div>';

    str += '<div class="divider-vertical"></div>';

    if (include.includes('link'))
      str +=
        '<div class="editor-btn" data-btn="link" aria-tooltip="link">\
          <i class="fa-solid fa-link"></i>\
        </div>';

    if (include.includes('quote'))
      str +=
        '<div class="editor-btn" data-btn="quote" aria-tooltip="quote block">\
          <i class="fa-solid fa-quote-left"></i>\
        </div>';

    if (include.includes('table'))
      str +=
        '<div class="editor-btn" data-btn="table" aria-tooltip="table">\
          <i class="fa-solid fa-table"></i>\
        </div>';

    str += '<div class="divider-vertical"></div>';

    if (include.includes('list-ul'))
      str +=
        '<div class="editor-btn" data-btn="list-ul" aria-tooltip="unordered list">\
          <i class="fa-solid fa-list-ul"></i>\
        </div>';
    if (include.includes('list-ol'))
      str +=
        '<div class="editor-btn" data-btn="list-ol" aria-tooltip="ordered list">\
          <i class="fa-solid fa-list-ol"></i>\
        </div>';

    str += '<div class="divider-vertical"></div>';

    if (include.includes('image'))
      str +=
        '<div class="editor-btn image-btn" data-btn="image" aria-tooltip="image">\
          <i class="fa-regular fa-image"></i>\
        </div>';
    return str;
  }

  /*
  inputTextElements() {
    return '<div class="editor-btn" data-btn="bold" aria-label="bold text">\
      <i class="fa-solid fa-bold"></i>\
    </div>\
    <div class="editor-btn px-2" data-btn="italic" aria-label="italic text">\
      <i class="fa-solid fa-italic"></i>\
    </div>\
    <div class="divider-vertical"></div>\
    <div class="editor-btn" data-btn="link" aria-label="link">\
      <i class="fa-solid fa-link"></i>\
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
    this.selection = '';
  }

  asString() {
    return this.selection == '' ? this.asPlaceholder() : this.withSelection();
  }

  asPlaceholder() {
    return this.prefix + this.placeholder + this.suffix;
  }

  wrapped(selection = this.selection) {
    return this.prefix + selection + this.suffix;
  }

  withSelection() {
    var lines = this.selection.split('\n');

    lines = lines.reduce(
      function (text, selection, index) {
        return index == 0
          ? this.wrapped(selection)
          : text + '\n' + this.wrapped(selection);
      }.bind(this),
      ''
    );

    // Account for accidental empty line selections before/after a group
    var wordSplit = this.selection.split(' '),
      first = wordSplit[0],
      last = wordSplit[this.selection.length - 1];
    if (first == '\n') lines.unshift(first);
    if (last == '\n') lines.push(last);

    return lines;
  }
}

class BlockAffix extends Affix {
  withSelection() {
    return this.multiline() + this.selection;
  }

  asPlaceholder() {
    return this.multiline() + this.placeholder;
  }

  multiline() {
    if (this.selection.includes('\n')) {
      return this.prefix + '. ';
    } else {
      return this.prefix + ' ';
    }
  }
}

class CursorInfo {
  constructor(start, end, text) {
    this.start = start;
    this.end = end;
    this.text = text;
  }

  hasSelection() {
    return !(this.start == this.end);
  }
}

$.fn.cursorInfo = function () {
  return this.map(function () {
    var startIndex = this.selectionStart,
      endIndex = this.selectionEnd,
      selectedText = $(this).val().substring(startIndex, endIndex);

    return new CursorInfo(startIndex, endIndex, selectedText);
  })[0];
};
