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
          wrap: '<div class="textile-wrap"><ul class="textile-toolbar"></ul><div class="textile-inner row" data-behavior="rich-toolbar"></div></div>',
          preview: '<div class="textile-preview loading-indicator">Loading...</div>',
          help: '<div class="textile-help col-12 loading-indicator">Loading...</div>'
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
      this._buildContainer();

      this._previousContent = this.$element.val();
      this._previewRendered = false;
      this._helpRendered = false;
    },
    _buildContainer: function() {
      // Add wrapper div with toolbar and inner container (see defaults.tpl)

      // container
      this.options.$wrap = $(this.options.tpl.wrap);
      this.$element.parent().append( this.options.$wrap );

      // move textarea to container
      $('.textile-inner', this.options.$wrap).append(this.$element);
      this.$element.addClass('h-100').attr('rows', 20).wrap('<div class="col-6"></div>');

      // add Preview to container and load
      this.options.$preview = $(this.options.tpl.preview);
      $('.textile-inner', this.options.$wrap).append(this.options.$preview);
      this.options.$preview.wrap('<div class="col-6"></div>');
      this._loadPreview();

      // Sync preview
      var typingTimer;
      var doneTypingInterval = 500;

      // on keyup, start the countdown
      this.$element.on('textchange load-preview', function () {
        clearTimeout(typingTimer);
        typingTimer = setTimeout(this._onKeyPressPreview.bind(this), doneTypingInterval);
      }.bind(this));

      // add Help to container and hide
      this.options.$help = $(this.options.tpl.help);
      $('.textile-inner', this.options.$wrap).append(this.options.$help)
      this.options.$help.hide();

      // toolbar
      this._buildToolbar();
    },
    _buildToolbar: function() {
      var button;

      // Write
      button = $('<a class="btn-write active" href="javascript:void(null);"><span>Write</span></a>');
      button.click( $.proxy( function(evt) { this._onBtnWrite(evt); }, this));
      $('.textile-toolbar', this.options.$wrap).append( $('<li>').append(button) );

      // Full screen
      // button = $('<a class="btn btn-fullscreen" href="javascript:void(null);"><span>&nbsp;</span></a>');
      button = $('<a class="btn-fullscreen fa fa-expand" href="javascript:void(null);"><span>&nbsp;</span></a>');
      button.click( $.proxy( function(evt) { this._onBtnFullScreen(evt); }, this));
      $('.textile-toolbar', this.options.$wrap).append( $('<li class="right">').append(button) );

      // Help
      button = $('<a class="btn-help fa fa-question" href="javascript:void(null);"><span>&nbsp;</span></a>');
      button.click( $.proxy( function(evt) { this._onBtnHelp(evt); }, this));
      $('.textile-toolbar', this.options.$wrap).append( $('<li class="right">').append(button) );
    },
    _buildResizer: function() {
      if (this.options.resize === false) return false;

    },
    // Ajax preview
    _loadPreview: function() {
      this._previousContent = this.$element.val();

      $.post(this.$element.data('preview-url'),
        { text: this.$element.val() },
        function(result) {
          this.options.$preview.removeClass('loading-indicator')
            .html(result);
          this._previewRendered = true;
        }.bind(this)
      );
    },
    // Ajax help
    _loadHelp: function() {
      $.get( this.$element.data('help-url'), function(result){
        this.options.$help.removeClass('loading-indicator')
          .html(result);
        this._helpRendered = true;
      }.bind(this));
    },
    _onKeyPressPreview: function() {
      // If the text hasn't changed, do nothing.
      if (this._previousContent == this.$element.val()) {
        if (!this._previewRendered) {
          this._loadPreview();
        }
      } else {
        this._loadPreview();
      }
    },
    // Toolbar button handlers
    _onBtnWrite: function() {
      // Activate toolbar button
      var scope = this.options.$wrap;
      $('.textile-toolbar a', scope).removeClass('active');
      $('.textile-toolbar .btn-write', scope).addClass('active');

      // Show Write pane
      this.options.$help.hide();
      this.$element.show();
      this.options.$preview.show();
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
        $(window).resize($.proxy(this._onFullScreenResize, this));

        // update button icon
        $btnFS.removeClass('fa-expand').addClass('fa-compress');

        // back to top for good measure
        $(document).scrollTop(0,0);
      }
      else
      {
        this.options.fullscreen = false;

        // stop listening to resize events
        $(window).unbind('resize', $.proxy(this._onFullScreenResize, this));
        $(document.body).css('overflow', 'visible');

        this.options.$wrap.removeClass('textile-fullscreen');
        this.options.$wrap.css('width', this.options.width);
        this.options.tmpspan.after(this.options.$wrap).remove();

        this.options.$preview.css('height', '100%');
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

      var hfix = 65;
      var height = $(window).height() - hfix;

      this.options.$wrap.width($(window).width()-20);
      this.options.$preview.height(height-44);
      this.$element.height(height-10);
    }
  };

  // A really lightweight plugin wrapper around the constructor,
  // preventing against multiple instantiations
  $.fn[pluginName] = function ( options ) {
    return this.each(function () {
      if (!$.data(this, 'plugin_' + pluginName)) {
        $.data(this, 'plugin_' + pluginName, new Plugin( this, options ));
      }
    });
  }
}(jQuery, window));
