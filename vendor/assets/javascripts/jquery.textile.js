// Textile editor plugin with Write/Preview/Fullscreen functionality
//
// References:
//   jQuery boilerplate - http://jqueryboilerplate.com/
//   Inspired in redactor.js - http://redactorjs.com/

// the semi-colon before function invocation is a safety net against concatenated
// scripts and/or other plugins which may not be closed properly.
;(function ( $, window, undefined ) {

  // undefined is used here as the undefined global variable in ECMAScript 3 is
  // mutable (ie. it can be changed by someone else). undefined isn't really being
  // passed in so we can ensure the value of it is truly undefined. In ES5, undefined
  // can no longer be modified.

  // window and document are passed through as local variables rather than globals
  // as this (slightly) quickens the resolution process and can be more efficiently
  // minified (especially when both are regularly referenced in your plugin).

  // Create the defaults once
  var pluginName = 'textile',
      document = window.document,
      defaults = {
        // Start fullscreen?
        fullscreen: false,
        // Add a resizer bar at the bottom of the editor
        resize: true,
        // HTML templates
        tpl: {
          wrap: '<div class="textile-wrap"><ul class="textile-toolbar"></ul><div class="textile-inner"></div></div>',
          preview: '<div class="textile-preview loading-indicator">Loading...</div>',
          help: '<div class="textile-help loading-indicator">Loading...</div>'
        }
      };

  // The actual plugin constructor
  function Plugin( element, options ) {
    this.$element = $(element);

    // jQuery has an extend method which merges the contents of two or
    // more objects, storing the result in the first object. The first object
    // is generally empty as we don't want to alter the default options for
    // future instances of the plugin
    this.options = $.extend( {}, defaults, options) ;

    this._defaults = defaults;
    this._name = pluginName;

    this.init();
  }

  Plugin.prototype = {
    init: function () {
      // Place initialization logic here
      // You already have access to the DOM element and the options via the instance,
      // e.g., this.element and this.options
      this._initElements();

      this._buildContainer();

      this._previousContent = this.$element.val();
      this._previewRendered = false;
      this._helpRendered = false;
    },
    // Add wrapper div with toolbar and inner container (see defaults.tpl)
    _buildContainer: function() {
      // Skip when textile is already initialized
      if (this.$element.data('textiled')) {
        this._buildToolbarHandlers();
        return;
      }

      // container
      this.$element.parent().append( this.options.$wrap );

      // move textarea to container
      $('.textile-inner', this.options.$wrap).append(this.$element);
      this.$element.css('resize', 'none');
      this.$element.css('width', '100%');
      this.$element.attr('rows', 20);

      // add Preview to container and hide
      $('.textile-inner', this.options.$wrap).append(this.options.$preview);
      this.options.$preview.hide();

      // add Help to container and hide
      $('.textile-inner', this.options.$wrap).append(this.options.$help)
      this.options.$help.hide();

      // toolbar
      this._buildToolbar();
      this._buildToolbarHandlers();

      this.$element.attr('data-textiled', 'true');
    },
    _buildToolbar: function() {
      var button;

      // Write
      button = $('<a class="btn-write active" href="javascript:void(0);"><span>Write</span></a>');
      $('.textile-toolbar', this.options.$wrap).append( $('<li>').append(button) );

      // Preview
      button = $('<a class="btn-preview" href="javascript:void(0);"><span>Preview</span></a>');
      $('.textile-toolbar', this.options.$wrap).append( $('<li>').append(button) );

      // Full screen
      // button = $('<a class="btn btn-fullscreen" href="javascript:void(0);"><span>&nbsp;</span></a>');
      button = $('<a class="btn-fullscreen fa fa-expand" href="javascript:void(0);"><span>&nbsp;</span></a>');
      $('.textile-toolbar', this.options.$wrap).append( $('<li class="right">').append(button) );

      // Help
      button = $('<a class="btn-help fa fa-question" href="javascript:void(0);"><span>&nbsp;</span></a>');
      $('.textile-toolbar', this.options.$wrap).append( $('<li class="right">').append(button) );
    },
    _buildToolbarHandlers: function() {
      $('.btn-write').click( function(evt) { this._onBtnWrite(evt) }.bind(this) );
      $('.btn-preview').click( function(evt) { this._onBtnPreview(evt) }.bind(this) );
      $('.btn-fullscreen').click( function(evt) { this._onBtnFullScreen(evt) }.bind(this) );
      $('.btn-help').click( function(evt) { this._onBtnHelp(evt) }.bind(this) );
    },
    _buildResizer: function() {
      if (this.options.resize === false) return false;
    },
    _initElements: function() {
      this.options.$wrap    = $(this.options.tpl.wrap);
      this.options.$preview = $(this.options.tpl.preview);
      this.options.$help    = $(this.options.tpl.help);
    },
    // Ajax preview
    _loadPreview: function() {
      this._previousContent = this.$element.val();
      this.options.$preview.addClass('loading-indicator').text('Loading...');

      var that = this;
      $.getJSON( this.$element.data('preview-url'), {text: this.$element.val()}, function(result){
        that.options.$preview.removeClass('loading-indicator')
          .html(result.html);
        that._previewRendered = true;
      });
    },
    // Ajax help
    _loadHelp: function() {
      var that = this;
      $.get( this.$element.data('help-url'), function(result){
        that.options.$help.removeClass('loading-indicator')
          .html(result);
        this._helpRendered = true;
      });
    },
    // Toolbar button handlers
    _onBtnWrite: function() {
      // Activate toolbar button
      var scope = this.options.$wrap;
      $('.textile-toolbar a', scope).removeClass('active');
      $('.textile-toolbar .btn-write', scope).addClass('active');

      // Show Write pane
      this.options.$preview.hide();
      this.options.$help.hide();
      this.$element.show();
    },
    _onBtnPreview: function() {
      // Activate toolbar button
      var scope = this.options.$wrap;
      $('.textile-toolbar a', scope).removeClass('active');
      $('.textile-toolbar .btn-preview', scope).addClass('active');

      // Show Preview pane
      this.$element.hide();

      this.options.$help.hide();
      this.options.$preview.show();

      // If the text hasn't changed, do nothing.
      if (this._previousContent == this.$element.val()) {
        if (!this._previewRendered) {
          this._loadPreview();
        }
      }
      else {
        this._loadPreview();
      }
    },
    _onBtnFullScreen: function() {
      $btnFS = $('.btn-fullscreen', this.options.$wrap);

      if (this.options.fullscreen === false ) {
        this.options.fullscreen = true;

        this.options.height = this.$element.css('height');
        this.options.width  = this.options.$wrap.css('width');

        this.options.tmpspan = $('<span></span>');
        this.options.$wrap.addClass('textile-fullscreen').after(this.options.tmpspan);

        $(document.body).prepend(this.options.$wrap).css('overflow', 'hidden');

        // fit to window
        this._onFullScreenResize();

        // refit whenever the window resizes
        $(window).resize(this._onFullScreenResize.bind(this));

        // update button icon
        $btnFS.removeClass('fa-expand').addClass('fa-compress');

        // back to top for good measure
        $(document).scrollTop(0,0);
      }
      else
      {
        this.options.fullscreen = false;

        // stop listening to resize events
        $(window).unbind('resize', this._onFullScreenResize.bind(this));
        $(document.body).css('overflow', 'visible');

        this.options.$wrap.removeClass('textile-fullscreen');
        this.options.$wrap.css('width', this.options.width);
        this.options.tmpspan.after(this.options.$wrap).remove();

        this.options.$preview.css('height', 'auto');
        this.$element.css('height', this.options.height);

        // update button icon
        $btnFS.removeClass('fa-compress').addClass('fa-expand');
      }
    },
    _onBtnHelp: function() {
      var scope = this.options.$wrap;
      $('.textile-toolbar a', scope).removeClass('active');
      $('.textile-toolbar .btn-help', scope).addClass('active');

      // Show Help pane
      this.$element.hide();
      this.options.$preview.hide();
      this.options.$help.show();

      if (!this._helpRendered) {
        this._loadHelp();
      }
    },

    // --------------------------------------------------- Other event handlers

    // Triggered by window resize events
    _onFullScreenResize: function(){
      if (this.options.fullscreen === false) return;

      var hfix = 42;
      var hfix = 60;
      var height = $(window).height() - hfix;

      this.options.$wrap.width($(window).width()-20);
      this.options.$preview.height(height);
      this.$element.height(height-10);
    }
  };

  // A really lightweight plugin wrapper around the constructor,
  // preventing against multiple instantiations
  $.fn[pluginName] = function ( options ) {
    return this.each(function () {
      // Reuse the same elements when re-initializing
      if ($(this).data('textiled')) {
        options = {
          tpl: {
            help: $('.textile-help'),
            preview: $('.textile-preview'),
            wrap: $('.textile-wrap')
          }
        }
      }
      new Plugin( this, options );
    });
  }

}(jQuery, window));
